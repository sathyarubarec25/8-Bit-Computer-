module alu(A,B,Sub,y,flag_out);

input [7:0] A;
input [7:0] B;
input Sub;

output reg [7:0] y;
output reg [1:0] flag_out;

reg [8:0] temp;

always @(*)
begin

    if (Sub == 1'b1)
    begin
        temp = {1'b0,A} - {1'b0,B};
        flag_out[1]=(A<B);
    end
    else
    begin
        temp = {1'b0,A} + {1'b0,B};
        flag_out[1]=temp[8];
    end

    y = temp[7:0];
    if (y == 8'b00000000)
        flag_out[0] = 1'b1;
    else
        flag_out[0] = 1'b0;

end

endmodule