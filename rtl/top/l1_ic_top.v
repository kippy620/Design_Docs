/*
 -- ============================================================================
 -- FILE NAME   : l1_ic_top.v
 -- DESCRIPTION : ram of cache
 -- ----------------------------------------------------------------------------
 -- Date:2016/4/12         Coding_by:kippy   
 -- ============================================================================
*/
`timescale 1ns/1ps
/********** General header file **********/
`include "stddef.h"
`include "icache.h"

module l1_ic_top(
    input            clk,           // clock
    input            rst,           // reset   
    /* CPU part */
    input    [29:0]  if_pc,         // address of fetching instruction
    output   [31:0]  insn,          // read data of CPU
    output           if_busy,       // the signal of stall caused by cache miss
    /* L2_cache part */
    input            ic_en,         // busy signal of L2_cache
    input            l2_rdy,        // ready signal of L2_cache
    input   [127:0]  data_wd_l2,    // write data of l2_cache
    input            mem_wr_ic_en, 
    output           complete_ic,   // complete write from L2 to L1
    output           irq,           // icache request
    output           ic_rw_en,      // enable signal of writing icache 
    output   [27:0]  l2_addr_ic,    // addr of l2_cache
    output           l2_cache_rw_ic,// write signal of l2_cache
    /* if_reg part */
    output           data_rdy       // tag hit mark
    );
    /*itag*/
    wire            block0_we;      // write signal of block0
    wire            block1_we;      // write signal of block1
    wire            block0_re;      // read signal of block0
    wire            block1_re;      // read signal of block1
    wire    [7:0]   index_ic;       // address of cache
    wire    [20:0]  tag_wd_ic;      // write data of tag
    wire    [20:0]  tag0_rd_ic;     // read data of tag0
    wire    [20:0]  tag1_rd_ic;     // read data of tag1
    wire            lru_ic;         // read data of lru_field
    /*idata*/  
    wire    [127:0] data0_rd_ic;    // read data of cache_data0
    wire    [127:0] data1_rd_ic;    // read data of cache_data1

    itag_ram itag_ram(
        .clk            (clk),              // clock
        .block0_we      (block0_we),        // write signal of block0
        .block1_we      (block1_we),        // write signal of block1
        .block0_re      (block0_re),        // read signal of block0
        .block1_re      (block1_re),        // read signal of block1
        .index          (index_ic),         // address of cache
        .tag_wd         (tag_wd_ic),        // write data of tag
        .tag0_rd        (tag0_rd_ic),       // read data of tag0
        .tag1_rd        (tag1_rd_ic),       // read data of tag1
        .lru            (lru_ic),           // read data of tag
        .complete       (complete_ic)       // complete write from L2 to L1
        );
    idata_ram idata_ram(
        .clk            (clk),             // clock
        .block0_we      (block0_we),       // write signal of block0
        .block1_we      (block1_we),       // write signal of block1
        .block0_re      (block0_re),       // read signal of block0
        .block1_re      (block1_re),       // read signal of block1
        .index          (index_ic),        // address of cache__
        .data_wd_l2     (data_wd_l2),      // write data of l2_cache
        .data0_rd       (data0_rd_ic),     // read data of cache_data0
        .data1_rd       (data1_rd_ic)      // read data of cache_data1
    );
    icache_ctrl icache_ctrl(
        .clk            (clk),             // clock
        .rst            (rst),             // reset
        /* CPU part */
        .if_addr        (if_pc),           // address of fetching instruction
        .rw             (`READ),           // read / write signal of CPU
        .cpu_data       (insn),            // read data from cache to CPU
        .miss_stall     (if_busy),         // the signal of stall caused by cache miss
        /* L1_cache part */
        .lru            (lru_ic),          // mark of replacing
        .tag0_rd        (tag0_rd_ic),      // read data of tag0
        .tag1_rd        (tag1_rd_ic),      // read data of tag1
        .data0_rd       (data0_rd_ic),     // read data of data0
        .data1_rd       (data1_rd_ic),     // read data of data1
        .data_wd_l2     (data_wd_l2),
        .tag_wd         (tag_wd_ic),       // write data of L1_tag
        .block0_we      (block0_we),       // write signal of block0
        .block1_we      (block1_we),       // write signal of block1
        .block0_re      (block0_re),       // read signal of block0
        .block1_re      (block1_re),       // read signal of block1
        .index          (index_ic),        // address of L1_cache
        /* l2_cache part */
        .ic_en          (ic_en),           // busy signal of l2_cache
        .l2_rdy         (l2_rdy),          // ready signal of l2_cache
        .mem_wr_ic_en   (mem_wr_ic_en), 
        .complete       (complete_ic),     // complete op writing to L1
        .irq            (irq),
        .ic_rw_en       (ic_rw_en),   
        .l2_addr        (l2_addr_ic),        
        .l2_cache_rw    (l2_cache_rw_ic),
        /* if_reg part */
        .data_rdy       (data_rdy)        
        );
endmodule