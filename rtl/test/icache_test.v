/*
 -- ============================================================================
 -- FILE NAME   : icache_test.v
 -- DESCRIPTION : testbench of icache
 -- ----------------------------------------------------------------------------
 -- Date:2016/1/18        Coding_by:kippy
 -- ============================================================================
*/
`timescale 1ns/1ps
/********** header file **********/
`include "stddef.h"
`include "icache.h"
`include "l2_cache.h"

module icache_test();
    // icache part
    reg              clk;           // clock
    reg              rst;           // reset
    /* CPU part */
    reg      [29:0]  if_addr;       // address of fetching instruction
    reg              rw;            // read / write signal of CPU
    wire     [31:0]  cpu_data;      // read data of CPU
    wire             miss_stall;    // the signal of stall caused by cache miss
    /* L1_cache part */
    wire             block0_we; 
    wire             block1_we; 
    wire             block0_re; 
    wire             block1_re; 
    wire     [20:0]  tag_wd;        // write data of L1_tag
    wire     [7:0]   index;         // address of L1_cache
    /* l2_cache part */
    wire             irq;           // icache request
    wire             drq;           // dcache request
    wire             ic_rw_en;      // write enable signal
    wire             dc_rw_en;
    // l2_icache
    wire     [27:0]  l2_addr_ic; 
    wire     [27:0]  l2_addr_dc;  
    wire             l2_cache_rw_ic;
    wire             l2_cache_rw_dc;
    wire     [8:0]   l2_index;
    wire     [1:0]   l2_offset;
    wire     [8:0]   l2_index_ic;      // address of cache
    /*cache part*/
    wire             ic_en;       // busy mark of L2C
    wire     [127:0] data_wd_l2;    // write data to L1 from L2
    wire     [127:0] data_wd_dc;    // write data to L1 from CPU
    wire             data_wd_l2_en; // enable signal of writing data to L1 from L2
    wire             data_wd_dc_en; // enable signal of writing data to L1 from L2
    wire     [127:0] rd_to_l2;
    wire             l2_block0_we;  // read / write signal of block0
    wire             l2_block1_we;  // read / write signal of block1
    wire             l2_block2_we;  // read / write signal of block2
    wire             l2_block3_we;  // read / write signal of block3
    wire             l2_block0_re;  // read / write signal of block0
    wire             l2_block1_re;  // read / write signal of block1
    wire             l2_block2_re;  // read / write signal of block2
    wire             l2_block3_re;  // read / write signal of block3
    wire     [17:0]  l2_tag_wd;     // write data of tag
    wire             l2_rdy;        // ready mark of L2C
    /*memory part*/
    wire     [25:0]  mem_addr;      // address of memory
    wire             mem_rw;        // read / write signal of memory
    wire     [511:0] mem_wd;
    reg      [511:0] mem_rd;
    reg              mem_complete;
    // tag_ram part
    wire     [20:0]  tag0_rd;       // read data of tag0
    wire     [20:0]  tag1_rd;       // read data of tag1
    wire             lru;           // read data of tag
    wire             complete_ic;      // complete write from L2 to L1 
    // data_ram part
    wire     [127:0] data0_rd;      // read data of cache_data0
    wire     [127:0] data1_rd;      // read data of cache_data1
    // l2_tag_ram part
    wire     [17:0]  l2_tag0_rd;    // read data of tag0
    wire     [17:0]  l2_tag1_rd;    // read data of tag1
    wire     [17:0]  l2_tag2_rd;    // read data of tag2
    wire     [17:0]  l2_tag3_rd;    // read data of tag3
    wire     [2:0]   plru;          // read data of tag
    wire             l2_complete;   // complete write from MEM to L2
    // l2_data_ram
    wire     [511:0] l2_data0_rd;    // read data of cache_data0
    wire     [511:0] l2_data1_rd;    // read data of cache_data1
    wire     [511:0] l2_data2_rd;    // read data of cache_data2
    wire     [511:0] l2_data3_rd;    // read data of cache_data3 
    // l2_dirty
    wire             l2_dirty_wd;
    wire             l2_dirty0;
    wire             l2_dirty1;
    wire             l2_dirty2;
    wire             l2_dirty3;
    reg              clk_tmp;        // temporary clock of L2C
    wire             data_rdy;
    wire             mem_wr_dc_en;
    wire             mem_wr_ic_en;
    
    icache_ctrl icache_ctrl(
        .clk            (clk),           // clock
        .rst            (rst),           // reset
        /* CPU part */
        .if_addr        (if_addr),       // address of fetching instruction
        .rw             (rw),            // read / write signal of CPU
        .cpu_data       (cpu_data),      // read data of CPU
        .miss_stall     (miss_stall),    // the signal of stall caused by cache miss
        /* L1_cache part */
        .lru            (lru), 
        .tag0_rd        (tag0_rd),       // read data of tag0
        .tag1_rd        (tag1_rd),       // read data of tag1
        .data0_rd       (data0_rd),      // read data of data0
        .data1_rd       (data1_rd),      // read data of data1
        .data_wd_l2     (data_wd_l2),
        .tag_wd         (tag_wd),        // write data of L1_tag
        .block0_we      (block0_we),     // write signal of block0
        .block1_we      (block1_we),     // write signal of block1
        .block0_re      (block0_re),     // read signal of block0
        .block1_re      (block1_re),     // read signal of block1
        .index          (index),         // address of L1_cache
        /* l2_cache part */
        .ic_en          (ic_en),         // busy signal of l2_cache
        .l2_rdy         (l2_rdy),        // ready signal of l2_cache
        .complete       (complete_ic),      // complete op writing to L1
        .mem_wr_ic_en   (mem_wr_ic_en),
        .irq            (irq),
        .ic_rw_en       (ic_rw_en),      
        .l2_addr        (l2_addr_ic),        
        .l2_cache_rw    (l2_cache_rw_ic), 
        .data_rdy       (data_rdy)        
        );
    l2_cache_ctrl l2_cache_ctrl(
        .clk            (clk),              // clock of L2C
        .rst            (rst),              // reset
        /* CPU part */
        .l2_addr_ic     (l2_addr_ic),       // address of fetching instruction
        .l2_cache_rw_ic (l2_cache_rw_ic),   // read / write signal of CPU
        .l2_addr_dc     (l2_addr_dc),       // address of fetching instruction
        .l2_cache_rw_dc (l2_cache_rw_dc),   // read / write signal of CPU
        .l2_index       (l2_index),
        .offset         (l2_offset),
        .tagcomp_hit    (l2_tagcomp_hit),   
        /*cache part*/
        .irq            (irq),           // icache request
        .drq            (drq),
        .ic_rw_en       (ic_rw_en),      // write enable signal of icache
        .dc_rw_en       (dc_rw_en),
        .complete_ic    (complete_ic),   // complete write from L2 to L1
        .complete_dc    (complete_dc),   // complete write from L2 to L1 
        .data_wd_l2     (data_wd_l2),    // write data to L1C       
        .data_wd_l2_en  (data_wd_l2_en), 
        .wd_from_l1_en  (wd_from_l1_en), 
        .wd_from_mem_en (wd_from_mem_en), 
        .mem_wr_dc_en   (mem_wr_dc_en), 
        .mem_wr_ic_en   (mem_wr_ic_en),
        /*l2_cache part*/
        .l2_complete    (l2_complete),   // complete write from MEM to L2
        .l2_rdy         (l2_rdy),
        .ic_en          (ic_en),
        .dc_en          (dc_en),
        // l2_tag part
        .plru           (plru),          // replace mark
        .l2_tag0_rd     (l2_tag0_rd),    // read data of tag0
        .l2_tag1_rd     (l2_tag1_rd),    // read data of tag1
        .l2_tag2_rd     (l2_tag2_rd),    // read data of tag2
        .l2_tag3_rd     (l2_tag3_rd),    // read data of tag3
        .l2_block0_we   (l2_block0_we),  // write signal of block0
        .l2_block1_we   (l2_block1_we),  // write signal of block1
        .l2_block2_we   (l2_block2_we),  // write signal of block2
        .l2_block3_we   (l2_block3_we),  // write signal of block3
        .l2_block0_re   (l2_block0_re),  // read signal of block0
        .l2_block1_re   (l2_block1_re),  // read signal of block1
        .l2_block2_re   (l2_block2_re),  // read signal of block2
        .l2_block3_re   (l2_block3_re),  // read signal of block3
        .l2_tag_wd      (l2_tag_wd),     // write data of tag0                
        // l2_data part
        .l2_data0_rd    (l2_data0_rd),   // read data of cache_data0
        .l2_data1_rd    (l2_data1_rd),   // read data of cache_data1
        .l2_data2_rd    (l2_data2_rd),   // read data of cache_data2
        .l2_data3_rd    (l2_data3_rd),   // read data of cache_data3
        // l2_dirty part
        .l2_dirty_wd    (l2_dirty_wd),
        .l2_dirty0      (l2_dirty0),
        .l2_dirty1      (l2_dirty1),
        .l2_dirty2      (l2_dirty2), 
        .l2_dirty3      (l2_dirty3),         
        /*memory part*/
        .mem_complete   (mem_complete),
        .mem_rd         (mem_rd),
        .mem_wd         (mem_wd), 
        .mem_addr       (mem_addr),     // address of memory
        .mem_rw         (mem_rw)        // read / write signal of memory
    );
    itag_ram itag_ram(
        .clk            (clk),           // clock
        .block0_we      (block0_we),     // write signal of tag0
        .block1_we      (block1_we),     // write signal of tag1
        .block0_re      (block0_re),     // read signal of tag0
        .block1_re      (block1_re),     // read signal of tag1
        .index          (index),         // address of cache
        .tag_wd         (tag_wd),        // write data of tag
        .tag0_rd        (tag0_rd),       // read data of tag0
        .tag1_rd        (tag1_rd),       // read data of tag1
        .lru            (lru),           // read data of tag
        .complete       (complete_ic)    // complete write from L2 to L1
        );
    idata_ram idata_ram(
        .clk            (clk),           // clock
        .block0_we      (block0_we),     // write signal of tag0
        .block1_we      (block1_we),     // write signal of tag1
        .block0_re      (block0_re),     // read signal of tag0
        .block1_re      (block1_re),     // read signal of tag1
        .index          (index),         // address of cache__
        .data_wd_l2     (data_wd_l2),    // write data of l2_cache
        .data0_rd       (data0_rd),      // read data of cache_data0
        .data1_rd       (data1_rd)       // read data of cache_data1
    );
    l2_data_ram l2_data_ram(
        .clk            (clk_tmp),       // clock of L2C
        .l2_index       (l2_index),
        .mem_rd         (mem_rd),
        .offset         (l2_offset),
        .rd_to_l2       (rd_to_l2),
        .wd_from_mem_en (wd_from_mem_en),
        .wd_from_l1_en  (wd_from_l1_en),
        .tagcomp_hit    (l2_tagcomp_hit),
        .l2_block0_we   (l2_block0_we),  // write signal of block0
        .l2_block1_we   (l2_block1_we),  // write signal of block1
        .l2_block2_we   (l2_block2_we),  // write signal of block2
        .l2_block3_we   (l2_block3_we),  // write signal of block3
        .l2_block0_re   (l2_block0_re),  // read signal of block0
        .l2_block1_re   (l2_block1_re),  // read signal of block1
        .l2_block2_re   (l2_block2_re),  // read signal of block2
        .l2_block3_re   (l2_block3_re),  // read signal of block3
        .l2_data0_rd    (l2_data0_rd),   // read data of cache_data0
        .l2_data1_rd    (l2_data1_rd),   // read data of cache_data1
        .l2_data2_rd    (l2_data2_rd),   // read data of cache_data2
        .l2_data3_rd    (l2_data3_rd)    // read data of cache_data3
    );
    l2_tag_ram l2_tag_ram(    
        .clk            (clk_tmp),       // clock of L2C
        .l2_block0_we   (l2_block0_we),  // write signal of block0
        .l2_block1_we   (l2_block1_we),  // write signal of block1
        .l2_block2_we   (l2_block2_we),  // write signal of block2
        .l2_block3_we   (l2_block3_we),  // write signal of block3
        .l2_block0_re   (l2_block0_re),  // read signal of block0
        .l2_block1_re   (l2_block1_re),  // read signal of block1
        .l2_block2_re   (l2_block2_re),  // read signal of block2
        .l2_block3_re   (l2_block3_re),  // read signal of block3
        .l2_index       (l2_index),
        .l2_tag_wd      (l2_tag_wd),     // write data of tag
        .l2_dirty_wd    (l2_dirty_wd),
        .l2_tag0_rd     (l2_tag0_rd),    // read data of tag0
        .l2_tag1_rd     (l2_tag1_rd),    // read data of tag1
        .l2_tag2_rd     (l2_tag2_rd),    // read data of tag2
        .l2_tag3_rd     (l2_tag3_rd),    // read data of tag3
        .plru           (plru),          // read data of plru_field
        .l2_complete    (l2_complete),   // complete write from L2 to L1
        .l2_dirty0      (l2_dirty0),
        .l2_dirty1      (l2_dirty1),
        .l2_dirty2      (l2_dirty2),
        .l2_dirty3      (l2_dirty3)
    );
 
    task icache_ctrl_tb;
        input  [31:0]  _cpu_data;        // read data of CPU
        input          _miss_stall;      // the signal of stall caused by cache miss
        /* L1_cache part */
        input          _block0_we;       // read / write signal of L1_block0
        input          _block1_we;       // read / write signal of L1_block1
        input  [20:0]  _tag_wd;          // write data of L1_tag
        input  [7:0]   _index;           // address of L1_cache
        /* l2_cache part */
        input          _irq;             // icache request
        input  [27:0]  _l2_addr_ic;
        begin 
            if( (cpu_data   === _cpu_data)          && 
                (miss_stall === _miss_stall)        && 
                (block0_we  === _block0_we)         && 
                (block1_we  === _block1_we)         && 
                (tag_wd     === _tag_wd)            && 
                (index      === _index)             && 
                (irq        === _irq)               && 
                (l2_addr_ic  === _l2_addr_ic)        
               ) begin 
                 $display("Icache Test Succeeded !"); 
            end else begin 
                 $display("Icache Test Failed !"); 
            end 
            if (cpu_data   !== _cpu_data) begin
                $display("cpu_data:%b(excepted %b)",cpu_data,_cpu_data); 
            end
            if (miss_stall !== _miss_stall) begin
                $display("miss_stall:%b(excepted %b)",miss_stall,_miss_stall); 
            end
            if (block0_we  !== _block0_we) begin
                $display("block0_we:%b(excepted %b)",block0_we,_block0_we); 
            end
            if (block1_we  !== _block1_we) begin
                $display("block1_we:%b(excepted %b)",block1_we,_block1_we); 
            end
            if (tag_wd     !== _tag_wd) begin
                $display("tag_wd:%b(excepted %b)",tag_wd,_tag_wd); 
            end
            if (index      !== _index) begin
                $display("index:%b(excepted %b)",index,_index); 
            end
            if (irq   !== _irq) begin
                $display("irq:%b(excepted %b)",irq,_irq); 
            end
            if (l2_addr_ic !== _l2_addr_ic) begin
                $display("l2_addr_ic:%b(excepted %b)",l2_addr_ic,_l2_addr_ic); 
            end
        end
    endtask 
    task l2_cache_ctrl_tb;
        input           _ic_en;            // L2C busy mark
        input   [127:0] _data_wd_l2;            // write data to L1_IC
        input           _l2_block0_we;       // read / write signal of block0
        input           _l2_block1_we;       // read / write signal of block1
        input           _l2_block2_we;       // read / write signal of block0
        input           _l2_block3_we;       // read / write signal of block1
        input   [17:0]  _l2_tag_wd;          // write data of tag0
        input           _l2_rdy;             // ready signal of l2_cache
        // l2_dirty part
        input           _l2_dirty_wd;
        input   [25:0]  _mem_addr;           // address of memory
        input           _mem_rw;             // read / write signal of memory
        begin 
            if( (ic_en         === _ic_en)          && 
                (data_wd_l2    === _data_wd_l2)     && 
                (l2_block0_we  === _l2_block0_we)   && 
                (l2_block1_we  === _l2_block1_we)   && 
                (l2_block2_we  === _l2_block2_we)   && 
                (l2_block3_we  === _l2_block3_we)   && 
                (l2_tag_wd     === _l2_tag_wd)      && 
                (l2_rdy        === _l2_rdy)         && 
                (l2_dirty_wd  === _l2_dirty_wd)     &&
                (mem_addr      === _mem_addr)       && 
                (mem_rw        === _mem_rw)  
               ) begin 
                 $display("l2_icache Test Succeeded !"); 
            end else begin 
                 $display("l2_icache Test Failed !"); 
            end 
            // check
            if(ic_en         !== _ic_en)     begin
                $display("ic_en Test Failed !"); 
            end
            if(data_wd_l2    !== _data_wd_l2)     begin
                $display("data_wd_l2:%b(excepted %b)",data_wd_l2,_data_wd_l2); 
            end
            if(l2_block0_we  !== _l2_block0_we)  begin
                $display("l2_block0_we Test Failed !"); 
            end
            if(l2_block1_we  !== _l2_block1_we)  begin
                $display("l2_block1_we Test Failed !"); 
            end
            if(l2_block2_we  !== _l2_block2_we)  begin
                $display("l2_block2_we Test Failed !"); 
            end
            if(l2_block3_we  !== _l2_block3_we)  begin
                $display("l2_block3_we Test Failed !"); 
            end
            if(l2_tag_wd     !== _l2_tag_wd)   begin
                $display("l2_tag_wd:%b(excepted %b)",l2_tag_wd,_l2_tag_wd); 
            end
            if(l2_rdy        !== _l2_rdy)      begin
                $display("l2_rdy Test Failed !"); 
            end
            if (l2_dirty_wd !== _l2_dirty_wd) begin
                $display("l2_dirty_wd Test Failed !"); 
            end
            if(mem_addr      !== _mem_addr)    begin
                $display("mem_addr Test Failed !"); 
            end
            if(mem_rw        !== _mem_rw) begin
                $display("mem_rw Test Failed !"); 
            end 
        end
    endtask
    task tag_ram_tb;
        input      [20:0]  _tag0_rd;        // read data of tag0
        input      [20:0]  _tag1_rd;        // read data of tag1
        input              _lru;            // read block of tag
        input              _complete_ic;    // complete_ic write from L2 to L1
        begin 
            if( (tag0_rd  === _tag0_rd)     && 
                (tag1_rd  === _tag1_rd)     && 
                (lru      === _lru)         && 
                (complete_ic === _complete_ic)              
               ) begin 
                 $display("Tag_ram Test Succeeded !"); 
            end else begin 
                 $display("Tag_ram Test Failed !"); 
            end             
            if (tag0_rd  !== _tag0_rd) begin
                $display("tag0_rd:%b(excepted %b)",tag0_rd,_tag0_rd); 
            end
            if (tag1_rd  !== _tag1_rd) begin
                $display("tag1_rd:%b(excepted %b)",tag1_rd,_tag1_rd); 
            end
            if (lru      !== _lru) begin
                $display("lru:%b(excepted %b)",lru,_lru); 
            end
            if (complete_ic !== _complete_ic) begin
                $display("complete_ic:%b(excepted %b)",complete_ic,_complete_ic); 
            end
        end
    endtask
    task data_ram_tb;
        input  [127:0] _data0_rd;        // read data of cache_data0
        input  [127:0] _data1_rd;        // read data of cache_data1
        begin 
            if( (data0_rd  === _data0_rd)   && 
                (data1_rd  === _data1_rd)             
               ) begin 
                 $display("Data_ram Test Succeeded !"); 
            end else begin 
                 $display("Data_ram Test Failed !"); 
            end 
            if (data0_rd      !== _data0_rd) begin
                $display("data0_rd:%b(excepted %b)",data0_rd,_data0_rd); 
            end
            if (data1_rd !== _data1_rd) begin
                $display("data1_rd:%b(excepted %b)",data1_rd,_data1_rd); 
            end
        end
    endtask 
    task l2_tag_ram_tb;    
        input      [18:0]  _l2_tag0_rd;        // read data of tag0
        input      [18:0]  _l2_tag1_rd;        // read data of tag1
        input      [18:0]  _l2_tag2_rd;        // read data of tag2
        input      [18:0]  _l2_tag3_rd;        // read data of tag3
        input      [2:0]   _plru;              // read data of tag
        input              _l2_complete;       // complete write from L2 to L1
        begin 
            if( (l2_tag0_rd  === _l2_tag0_rd)   && 
                (l2_tag1_rd  === _l2_tag1_rd)   && 
                (l2_tag2_rd  === _l2_tag2_rd)   && 
                (l2_tag3_rd  === _l2_tag3_rd)   && 
                (plru        === _plru)         && 
                (l2_complete === _l2_complete)
               ) begin 
                 $display("l2_tag_ram Test Succeeded !"); 
            end else begin 
                 $display("l2_tag_ram Test Failed !"); 
            end 
            if (l2_tag0_rd  !== _l2_tag0_rd) begin
                $display("l2_tag0_rd:%b(excepted %b)",l2_tag0_rd,_l2_tag0_rd); 
            end
            if (l2_tag1_rd  !== _l2_tag1_rd) begin
                $display("l2_tag1_rd:%b(excepted %b)",l2_tag1_rd,_l2_tag1_rd); 
            end
            if (l2_tag2_rd  !== _l2_tag2_rd) begin
                $display("l2_tag2_rd:%b(excepted %b)",l2_tag2_rd,_l2_tag2_rd); 
            end
            if (l2_tag3_rd  !== _l2_tag3_rd) begin
                $display("l2_tag3_rd:%b(excepted %b)",l2_tag3_rd,_l2_tag3_rd); 
            end
            if (plru        !== _plru) begin
                $display("plru:%b(excepted %b)",plru,_plru); 
            end
            if (l2_complete !== _l2_complete) begin
                $display("l2_complete:%b(excepted %b)",l2_complete,_l2_complete); 
            end
        end
    endtask
    task l2_data_ram_tb;
        input  [511:0] _l2_data0_rd;         // read data of cache_data0
        input  [511:0] _l2_data1_rd;         // read data of cache_data1
        input  [511:0] _l2_data2_rd;         // read data of cache_data2
        input  [511:0] _l2_data3_rd;         // read data of cache_data3
        begin 
            if( (l2_data0_rd  === _l2_data0_rd)   && 
                (l2_data1_rd  === _l2_data1_rd)   && 
                (l2_data2_rd  === _l2_data2_rd)   && 
                (l2_data3_rd  === _l2_data3_rd)                 
               ) begin 
                 $display("l2_data_ram Test Succeeded !"); 
            end else begin 
                 $display("l2_data_ram Test Failed !"); 
            end 
            if (l2_data0_rd  !== _l2_data0_rd) begin
                $display("l2_data0_rd:%b(excepted %b)",l2_data0_rd,_l2_data0_rd); 
            end
            if (l2_data1_rd  !== _l2_data1_rd) begin
                $display("l2_data1_rd:%b(excepted %b)",l2_data1_rd,_l2_data1_rd); 
            end
            if (l2_data2_rd  !== _l2_data2_rd) begin
                $display("l2_data2_rd:%b(excepted %b)",l2_data2_rd,_l2_data2_rd); 
            end
            if (l2_data3_rd  !== _l2_data3_rd) begin
                $display("l2_data3_rd:%b(excepted %b)",l2_data3_rd,_l2_data3_rd); 
            end
        end
        
    endtask

    /******** Define Simulation Loop********/ 
    parameter  STEP = 10; 

    /******* Generated Clocks *******/
    always #(STEP / 2)
        begin
            clk = ~clk;  
        end
    always #STEP
        begin
            clk_tmp = ~clk_tmp;  
        end          
    /********** Testbench **********/
    initial begin
        #0 begin
            clk     <= `ENABLE;
            clk_tmp <= `ENABLE;
            rst     <= `ENABLE;

        end
        #(STEP * 3/4)
        #STEP begin 
            /******** Initialize Test Output ********/
            rst     <= `DISABLE;      
            if_addr <= 30'b1110_0001_0000_00;
            rw      <= `READ;
            mem_rd  <= 512'h123BC000_0876547A_00000000_ABF00000_123BC000_00000000_0876547A_00000000_ABF00000_123BC000;      // write data of l2_cache
            // IC_ACCESS & L2_IDLE 
            $display("\n========= Clock 0 ========");
            l2_cache_ctrl_tb(         
                `ENABLE,           // ic_en
                128'bx,            // write data to L1_IC
                1'bx,              // read / write signal of tag0
                1'bx,              // read / write signal of tag1
                1'bx,              // read / write signal of tag2
                1'bx,              // read / write signal of tag3
                18'b1_xxxx_xxxx_xxxx_xxxx_x,             // write data of tag
                1'bx,          // ready signal of l2_cache
                1'bx,
                26'bx,              // address of memory
                1'bx                // read / write signal of memory                
                );  
        end
        #STEP begin // IC_ACCESS_L2 & ACCESS_L2 
            $display("\n========= Clock 1 ========");
            l2_cache_ctrl_tb(          
                `ENABLE,           // ic_en
                // write data to L1_IC
                128'h0876547A_00000000_ABF00000_123BC000, 
                `ENABLE,           // read / write signal of tag0
                1'bx,              // read / write signal of tag1
                1'bx,              // read / write signal of tag2
                1'bx,              // read / write signal of tag3
                18'b1_0000_0000_0000_0000_1,              // write data of tag
                1'bx,           // ready signal of l2_cache
                1'b0,
                26'b1110_0001_00,   // address of memory
                `READ               // read / write signal of memory                
                );
            l2_tag_ram_tb(   
                18'bx,            // read data of tag0
                18'bx,            // read data of tag1
                18'bx,            // read data of tag2
                18'bx,            // read data of tag3
                3'bxxx,           // read data of tag
                `DISABLE          // complete write from L2 to L1
            );
            icache_ctrl_tb(
                32'h123BC000,   // read data of CPU
                `ENABLE,        // the signal of stall caused by cache miss
                `ENABLE,         // read / write signal of L1_tag0
                1'bx,          // read / write signal of L1_tag1
                21'b1_0000_0000_0000_0000_1110,           // tag_wd
                8'b0001_0000,   // address of L1_cache
                `ENABLE,        // icache request
                28'b1110_0001_0000  // l2_addr
                );
        end            
        #STEP begin // WRITE_IC & WRITE_TO_L2_CLEAN & access l2_ram
            $display("\n========= Clock 2 ========"); 
            icache_ctrl_tb(
                32'h123BC000,   // read data of CPU
                `DISABLE,       // the signal of stall caused by cache miss
                `READ,          // read / write signal of L1_tag0
                `READ,          // read / write signal of L1_tag1
                21'b1_0000_0000_0000_0000_1110,       // write data of L1_tag
                8'b0001_0000,   // address of L1_cache
                `DISABLE,       // icache request
                28'b1110_0001_0000 // l2_addr
                );
            tag_ram_tb(
                21'b1_0000_0000_0000_0000_1110,         // read data of tag0
                21'bx,                                  // read data of tag1
                1'b1,                                   // number of replacing block of tag next time
                1'b1                                    // complete write from L2 to L1
                );
            data_ram_tb(
                128'h0876547A_00000000_ABF00000_123BC000,   // read data of cache_data0
                128'hx                                      // read data of cache_data1
                ); 
            l2_cache_ctrl_tb(         
                `ENABLE,            // L2C busy mark
                128'h0876547A_00000000_ABF00000_123BC000,             // write data to L1_IC
                `ENABLE,           // read / write signal of tag0
                1'bx,              // read / write signal of tag1
                1'bx,              // read / write signal of tag2
                1'bx,              // read / write signal of tag3
                18'b1_0000_0000_0000_0000_1,              // write data of tag
                1'bx,           // ready signal of l2_cache
                1'b0,
                26'b1110_0001_00,   // address of memory
                `READ               // read / write signal of memory                
                );  
        end            
        #STEP begin // IC_ACCESS & WRITE_TO_L2_CLEAN & access l2_ram
            $display("\n========= Clock 3 ========");            
            icache_ctrl_tb(
                32'h123BC000,   // read data of CPU
                `DISABLE,       // the signal of stall caused by cache miss
                `READ,          // read / write signal of L1_tag0
                `READ,          // read / write signal of L1_tag1
                21'b1_0000_0000_0000_0000_1110,       // write data of L1_tag
                8'b0001_0000,   // address of L1_cache
                `DISABLE,       // icache request
                28'b1110_0001_0000 // l2_addr
                ); 
            l2_tag_ram_tb(   
                18'b1_0000_0000_0000_0000_1,    // read data of tag0
                18'bx,                          // read data of tag1
                18'bx,                          // read data of tag2
                18'bx,                          // read data of tag3
                3'bx11,                         // read data of tag
                `ENABLE                         // complete write from L2 to L1
            );
            l2_data_ram_tb(
                512'h123BC000_0876547A_00000000_ABF00000_123BC000_00000000_0876547A_00000000_ABF00000_123BC000,         // read data of cache_data0
                512'bx,             // read data of cache_data1
                512'bx,             // read data of cache_data2
                512'bx              // read data of cache_data3
             );
            l2_cache_ctrl_tb(      
                `DISABLE,           // L2C busy mark
                128'h0876547A_00000000_ABF00000_123BC000,             // write data to L1_IC
                `READ,              // read / write signal of tag0
                `READ,              // read / write signal of tag1
                `READ,              // read / write signal of tag2
                `READ,              // read / write signal of tag3
                18'b1_0000_0000_0000_0000_1,              // write data of tag
                1'bx,           // rdy signal of l2_cache
                1'b0,
                26'b1110_0001_00,   // address of memory
                `READ               // read / write signal of memory                
                ); 
            tag_ram_tb(
                21'b1_0000_0000_0000_0000_1110,         // read data of tag0
                21'bx,                                  // read data of tag1
                1'b1,                                   // number of replacing block of tag next time
                1'b0                                    // complete write from L2 to L1
                );
            data_ram_tb(
                128'h0876547A_00000000_ABF00000_123BC000,   // read data of cache_data0
                128'hx                                      // read data of cache_data1
                ); 
            $finish;     // iverilog
        end
        // #10 $stop;       // modelsim       
    end
    /********** output wave **********/
    initial begin
        $dumpfile("icache.vcd");
        $dumpvars(0,icache_ctrl,itag_ram,idata_ram,l2_tag_ram,l2_data_ram,l2_cache_ctrl);
    end
endmodule 