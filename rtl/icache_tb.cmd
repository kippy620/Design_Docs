iverilog -s tb_icache -o tb_icache.out -I ../../include tb_icache.v icache.v icache_ram.v
vvp tb_icache.out