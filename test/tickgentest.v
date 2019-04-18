`timescale 1ns/10ps

module tickgentest();
localparam MAX_SLEN = 32;

//==Signals
reg     [15:0]          presc;
wire                    tick;
reg                     clk;
reg                     reset_n;
reg     [MAX_SLEN*8:0]  tname;

//==VCD
initial
begin
    $dumpfile( "tickgentest.vcd" );
    $dumpvars;
end

//==Reset Sequence
initial
begin
    $display( "Test presc = 5" );
    tname = "PRESC = 5";
    clk = 0;
    reset_n = 0;
    presc = 16'd5;
    @(posedge clk) reset_n = 1'b1;

    #200 $display( "Test presc = 1 alisa passthrough" );
    tname = "PASSTHROUGH";
    clk = 0;
    reset_n = 0;
    presc = 16'd1;
    @(posedge clk) reset_n = 1'b1;

    #200 $display( "Test presc = 0 alisa stop" );
    tname = "STOP";
    clk = 0;
    reset_n = 0;
    presc = 16'd0;
    @(posedge clk) reset_n = 1'b1;

    #200 $finish;
end

always #2 clk = ~clk;

//==DUT
uart1655_axil_tickgen dut
(
    .presc(presc),
    .tick(tick),
    .clk(clk),
    .reset_n(reset_n)
);

endmodule
