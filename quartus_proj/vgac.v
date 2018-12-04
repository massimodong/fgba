/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
module vgac (vga_clk,clrn,d_in,row_addr,col_addr,rdn,r,g,b,hs,vs);
    input     [14:0] d_in;     // rrrrr_ggggg_bbbbb, pixel
    input            vga_clk;  // 25MHz
    input            clrn;
    output reg [8:0] row_addr; // pixel ram row address, 480 (512) lines
    output reg [9:0] col_addr; // pixel ram col address, 640 (1024) pixels
    output reg [4:0] r,g,b;    // red, green, blue colors, 5-bit for each
    output reg       rdn;      // read pixel RAM (active low)
    output reg       hs,vs;    // horizontal and vertical synchronization
    // h_count: vga horizontal counter (0-799 pixels)
    reg [9:0] h_count = 10'd0;
    always @ (posedge vga_clk or negedge clrn) begin
        if (!clrn) begin
            h_count <= 10'h0;
        end else if (h_count == 10'd799) begin // 800 pixels per line
            h_count <= 10'h0;
        end else begin 
            h_count <= h_count + 10'h1;
        end
    end
    // v_count: vga vertical counter (0-524 lines)
    reg [9:0] v_count = 10'd0;
    always @ (posedge vga_clk or negedge clrn) begin
        if (!clrn) begin
            v_count <= 10'h0;
        end else if (h_count == 10'd799) begin
            if (v_count == 10'd524) begin // 525 lines per frame
                v_count <= 10'h0;
            end else begin
                v_count <= v_count + 10'h1;
            end
        end
    end
    // signals, will be latched for outputs
    wire [9:0] row    =  v_count - 10'd35;     // ( 2+33= 35) pixel ram row address 
    wire [9:0] col    =  h_count - 10'd143;    // (96+48=144) pixel ram col address 
    wire       h_sync = (h_count > 10'd95);    //  96 -> 799
    wire       v_sync = (v_count > 10'd1);     //   2 -> 524
    wire       read   = (h_count > 10'd142) && // 143 -> 782 =
                        (h_count < 10'd783) && //              640 pixels
                        (v_count > 10'd34)  && //  35 -> 514 =
                        (v_count < 10'd515);   //              480 lines
    // vga signals
    always @ (posedge vga_clk) begin           // posedge orginal
        row_addr <=  row[8:0];                 // pixel ram row address
        col_addr <=  col;                      // pixel ram col address
        rdn      <= ~read;                     // read pixel (active low)
        hs       <=  h_sync;                   // horizontal synch
        vs       <=  v_sync;                   // vertical   synch
        r        <=  rdn ? 5'h0 : d_in[4:0]; // 5-bit red
        g        <=  rdn ? 5'h0 : d_in[9:5]; // 5-bit green
        b        <=  rdn ? 5'h0 : d_in[14:10]; // 5-bit blue
    end
endmodule