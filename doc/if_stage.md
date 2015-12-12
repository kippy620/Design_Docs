## Instruction Fetch（IF）阶段设计与实现

### IF 阶段

IF 阶段的操作有取指令，并决定下一条 PC 寄存器的内容。 IF 阶段由流水线寄存器与总线接口组成。表 1-1 列出了 IF 阶段的模块一览。

![Table 1-1](/image/if_modules.png)

IF 阶段是根据 PC 寄存器的值进行指令读取的。因为要先确定 PC 的值才可以进行指令读取，因此，指令存储到指令寄存器中的操作发生在 PC 值确定后的下一个时钟周期。这样，指令和 PC 寄存器对应的内容错开一个周期。而且由于 SPM 也按照时钟上升沿同步读取动作，因此从 SPM 读取指令时还要延迟一个周期。这样，指令与 PC 寄存器的对应内容会错开两个周期，造成周期浪费。这时可以选择考虑使用多相时钟电路，即多个时钟的数字电路设计。由于多相时钟设计会导致电路动作复杂、难以验证，所以不应过多使用。 FMC 只在 SPM 读取时使用 180 度相位的时钟。使用 180 度相位时钟的话， SPM 访问的时序会变得紧张。由于在 180 度相位时钟上升沿读取的数据，要在相位 0 度时钟上升沿进行锁存，实质上要求 SPM 数据读取速度为之前的两倍。如图 1-1 的 2 相时钟的 SPM 读取。

![Figure 1-1](/image/data_write_SPM.png)

### IF 阶段的流水线寄存器

IF 阶段的流水线寄存器（if_reg）的信号线一览如表 1-2 所示。

![Table 1-2](/image/if_signals.png)

IF 阶段的流水线寄存器（if_reg）的程序如下所示。
```python
module if_reg(input reset,clk,stall,flush,
	       input  [290] new_pc,br_taken,
	       input  [310] insn,
	       output [290] if_pc,
	       output [310] if_insn,
	       output if_en);

always @(posedge clk)
    begin
          if (reset == 1)
	          begin
	/********************异步复位********************/
	              if_pc = #1 30'b0;
	              if_insn = #1 32'b0;
	              if_en = #1 0;
	          end
          else
	        begin
	/*************更新流水线寄存器***************/
	            if (stall == 0)
	                begin
	                  if (flush == 1)                    
	                  //刷新
		                  begin
		                      if_pc = #1 new_pc;
		                      if_insn = #1 32'b0;
		                      if_en = #1 0;
		             ?????end?
	                  else if (br_taken == 1)
		                  begin //分支成立
		                      if_pc = #1 br_addr;
		                      if_insn = #1 insn;
		                      if_en = #1 1;
		                 end
	                  else                                     
	                      /*************下一条地址***************/
		                  begin
		                      if_pc = #1 if_pc + 1'd1;
		                      if_insn = #1 insn;
		                      if_en = #1 1;
		                  end
	                end
	    end
    end
endmodule
```
［Ⅰ］异步复位
复位信号（reset）有效时寄存器将被初始化。 PC（if_pc）设置为复位向量（地址 0），指令寄存器（if_insn）设置为 NOP，流水线数据有效标志位（if_en）设置为无效。

［Ⅱ］流水线寄存器的更新
流水线寄存器在延迟信号（stall）无效时才能更新。

（1）处对流水线寄存器进行刷新操作。刷新信号（flush）有效时，PC（if_PC）设置为新地址（new_pc），指令寄存器（if_insn）设置为 NOP，流水线数据有效标志位（if_en）设置为无效。

（2）处对分支进行处理。分支信号（br_taken）有效时，PC（if_pc）被设置为分支目的地址（br_addr）。指令寄存器（if_insn）设置为读取的指令（insn）、流水线数据有效标志位（if_en）设置为有效。

（3）处对 PC 的步进进行处理。在既没发生延迟也没发生分支的情况下， PC（if_pc）更新为下一条指令的地址（if_pc + 1'd1）。指令寄存器（if_insn）设置为读取的指令（insn）、流水线数据有效标志位（if_en）设置为有效。

###IF 阶段的顶层模块

IF 阶段的顶层模块用于连接总线接口与 IF 阶段的流水线寄存器。 由于 IF
阶段只进行指令的读取，总线接口的读  写信号（rw）设置为读取（READ），写入的数据（wr_data）设置为 0。由于每个时钟周期都会进行指令的读取，持续将地址有效信号（as_）设置为有效（ENABLE_）。

**目前未实现总线部分，故只考虑 IF 阶段的流水线寄存器**

故 IF 阶段的顶层模块的连接图如图 1-2 所示。

![Figure 1-2](/image/if_stage.png)
