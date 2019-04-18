`timescale 1ns/10ps

`define assert( signal, value )\
    if( signal != value ) begin\
        $display( "[%010d] Assertion Failed! signal != value @ %m", $time );\
        $finish;\
    end\

module fifotest();
localparam MAX_SLEN = 32;

//==Signals
reg     [7:0]   scratch;
reg     [7:0]   rdata;
reg     [7:0]   wdata;
reg     [7:0]   i;
reg             regmode = 1'b0;
reg     [7:0]   idata;
reg             write;
wire    [7:0]   odata;
reg             read;
wire    [4:0]   elems;
wire            empty;
wire            full;
wire            oeflag;
reg             clear_flag = 1'b0;
reg             clk;
reg             reset_n;
reg     [MAX_SLEN*8:0]  tname;

//==Tasks
task enqueue(
    input [7:0]   data
);
begin
    @(posedge clk) begin
        write <= 1'b1;
        idata <= data;
    end

    @(posedge clk) write <= 1'b0;
end
endtask

task enqueu_clear_oe(
    input [7:0] data
);
begin
    @(posedge clk) begin
        write <= 1'b1;
        idata <= data;
        clear_flag <= 1'b1;
    end

    @(posedge clk) begin
        write <= 1'b0;
        clear_flag <= 1'b0;
    end
end
endtask


task dequeue(
    output  reg     [7:0]    data
);
begin
    @(posedge clk) begin
        read <= 1'b1;
        data <= odata;
    end

    @(posedge clk) read = 1'b0;
end
endtask

task en_dequeue(
    input           [7:0]   wdata,
    output  reg     [7:0]   rdata
);
begin
    @(posedge clk) begin
        read = 1'b1;
        write = 1'b1;
        idata = wdata;
    end

    @(posedge clk) begin
        rdata = odata;
        read = 1'b0;
        write = 1'b0;
    end
end
endtask

task clear_oe;
begin
    @(posedge clk) clear_flag <= 1'b1;
    @(posedge clk) clear_flag <= 1'b0;
end
endtask


task fifo_normal_test;
begin
    //Init
    regmode = 0;
    read = 0;
    write = 0;
    clk = 0;
    reset_n = 0;
    i = 0;
    scratch = 0;
    wdata = 0;
    rdata = 0;

    //ASSD Reset
    @(posedge clk) reset_n = 1'b1;

    `assert( elems, 5'h00 );
    `assert( full, 1'b0 );
    `assert( empty, 1'b1 );
    `assert( oeflag, 1'b0);

    //Fill fifo full
    repeat(16) begin
        enqueue(wdata);
        wdata = wdata + 1;
    end
    
    //Try force fill 
    enqueue( 8'hff );
    //Check Interrupt Flag
    @(posedge clk) `assert( oeflag, 1'b1);
    clear_oe();
    @(posedge clk) `assert( oeflag, 1'b0);
    //Clear & force fill
    enqueu_clear_oe( 8'hff );
    @(posedge clk) `assert( oeflag, 1'b1);

    clear_oe();
    @(posedge clk) begin
        `assert( elems, 5'h10 );
        `assert( full, 1'b1 );
        `assert( empty, 1'b0 );
        `assert( oeflag, 1'b0);
    end

    //Dequeue first element
    dequeue( scratch );
    `assert( scratch, rdata );
    rdata = rdata + 1;

    repeat(100) begin
        en_dequeue( wdata, scratch );
        `assert( scratch, rdata );
        rdata = rdata + 1;
        wdata = wdata + 1;
    end
end
endtask

//==VCD
initial
begin
    clk = 0;
    $dumpfile( "fifotest.vcd" );
    $dumpvars;
end

always #2 clk = ~clk;

initial
begin
    fifo_normal_test();
    #20 $finish;
end

//==DUT
uart1655_axil_fifo dut(
    .regmode(regmode),
    .idata(idata),
    .write(write),
    .odata(odata),
    .read(read),
    .elems(elems),
    .empty(empty),
    .full(full),
    .oeflag(oeflag),
    .clear_flag(clear_flag),
    .clk(clk),
    .reset_n(reset_n)
);

endmodule
