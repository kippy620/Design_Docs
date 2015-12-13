## Instruction Fetch（IF）阶段设计与实现

### IF 阶段

IF 阶段的操作有取指令，并决定下一条 PC 寄存器的内容。 IF 阶段由流水线寄存器与总线接口组成。表 1-1 列出了 IF 阶段的模块一览。

| 模块名        | 文件名   |  说明  |
| :---- | :----  | :----  |
| if_stage | if_stage.v  | IF  阶段顶层模块    |
| if_reg   | if_reg.v    | IF 阶段流水线寄存器 |
| bus_if   | bus_if.v    | 总线接口            |

IF 阶段是根据 PC 寄存器的值进行指令读取的。因为要先确定 PC 的值才可以进行指令读取，因此，指令存储到指令寄存器中的操作发生在 PC 值确定后的下一个时钟周期。这样，指令和 PC 寄存器对应的内容错开一个周期。而且由于 SPM 也按照时钟上升沿同步读取动作，因此从 SPM 读取指令时还要延迟一个周期。这样，指令与 PC 寄存器的对应内容会错开两个周期，造成周期浪费。这时可以选择考虑使用多相时钟电路，即多个时钟的数字电路设计。由于多相时钟设计会导致电路动作复杂、难以验证，所以不应过多使用。 FMC 只在 SPM 读取时使用 180 度相位的时钟。使用 180 度相位时钟的话， SPM 访问的时序会变得紧张。由于在 180 度相位时钟上升沿读取的数据，要在相位 0 度时钟上升沿进行锁存，实质上要求 SPM 数据读取速度为之前的两倍。如图 1-1 的 2 相时钟的 SPM 读取。

![Figure 1-1](/image/data_write_SPM.png)

### IF 阶段的流水线寄存器

IF 阶段的流水线寄存器（if_reg）的信号线一览如表 1-2 所示。

| 分组        	| 信号名   	|  信号类型  	| 数据类|位宽	|含义			|
| :---- 	| :----  	| :----  	| :---- | :---- | :----  		|
|时钟		|clk		|输入端口	|wire	|1	|时钟			|
|复位		|reset		|输入端口	|wire	|1	|异步复位		|
|读取数据	|insn		|输入端口	|wire	|32	|读取的指令		|
|流水线控制信号	|stall		|输入端口	|wire	|1	|延迟			|
|流水线控制信号	|flush		|输入端口	|wire	|1	|刷新			|
|流水线控制信号	|new_pc		|输入端口	|wire	|30	|新程序计数器值		|
|流水线控制信号	|br_taken	|输入端口	|wire	|1	|分支发生		|
|流水线控制信号	|br_addr	|输入端口	|wire	|30	|分支目标地址		|
|IF/ID流水线寄存器|if_pc	|输入端口	|reg	|30	|程序计数器		|
|IF/ID流水线寄存器|if_insn 	|输入端口	|reg	|32	|指令			|
|IF/ID流水线寄存器|if_en   	|输入端口	|reg	|1	|流水线数据有效标志位	|

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
		                  end 
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

###IF 阶段的顶层模块

**目前未实现总线部分，故只考虑 IF 阶段的流水线寄存器**

故 IF 阶段的顶层模块的连接图如图 1-2 所示。

![Figure 1-2](/image/if_stage.png)
