-------------------------------------------------------------------------------
-- Title      : round computing for decoder
-- Project    : AES IP Core
-------------------------------------------------------------------------------
-- File       : round_encoder.vhdl
-- Author     : Rachid DAFALI  
-- Company    : 
-- Created    : 2012-11-23
-- Last update: 2012-11-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Licence   : This work is licensed under the Creative Commons
--             Attribution-NonCommercial-ShareAlike 3.0 Unported License.
--             To view a copy of this license, visit
--             http://creativecommons.org/licenses/by-nc-sa/3.0/. 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-11-23  1.0      rachid	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.aes_pkg.all;

entity round_encoder is
  
  port (
    in_clk                      : in  std_logic;
    in_reset                    : in  std_logic;
    in_cipher_key               : in  std_logic_vector(0 to 127);
    in_intermediate_data        : in  std_logic_vector(0 to 127);
    in_intermediate_data_valid  : in  std_logic;
    out_intermediate_data       : out std_logic_vector(0 to 127);
    out_intermediate_data_valid : out std_logic);

end entity round_encoder;

architecture arch_round_encoder of round_encoder is

begin  

round : process (in_clk, in_reset, in_intermediate_data_valid) is
begin 
  if in_reset = '0' then                
    out_intermediate_data_valid <= '0';
    out_intermediate_data <= X"00000000000000000000000000000000";
  elsif in_clk'event and in_clk = '1' then  
    if  in_intermediate_data_valid  = '1' then
      out_intermediate_data_valid <= '1';

      
      out_intermediate_data(0  to 31) <= sbox_encoding_0(to_integer(unsigned(in_intermediate_data(0   to   7)))) xor
                                        sbox_encoding_1(to_integer(unsigned(in_intermediate_data(40  to  47)))) xor
                                        sbox_encoding_2(to_integer(unsigned(in_intermediate_data(80  to  87)))) xor
                                        sbox_encoding_3(to_integer(unsigned(in_intermediate_data(120 to 127)))) xor
                                        in_cipher_key(0  to 31);
      out_intermediate_data(32 to 63) <= sbox_encoding_0(to_integer(unsigned(in_intermediate_data(32  to  39)))) xor
                                        sbox_encoding_1(to_integer(unsigned(in_intermediate_data(72  to  79)))) xor
                                        sbox_encoding_2(to_integer(unsigned(in_intermediate_data(112 to 119)))) xor
                                        sbox_encoding_3(to_integer(unsigned(in_intermediate_data(24  to  31)))) xor
                                        in_cipher_key(32  to 63);
      out_intermediate_data(64 to 95) <= sbox_encoding_0(to_integer(unsigned(in_intermediate_data(64  to  71)))) xor
                                        sbox_encoding_1(to_integer(unsigned(in_intermediate_data(104 to 111)))) xor
                                        sbox_encoding_2(to_integer(unsigned(in_intermediate_data(16  to  23)))) xor
                                        sbox_encoding_3(to_integer(unsigned(in_intermediate_data(56  to  63)))) xor
                                        in_cipher_key(64  to 95);
      out_intermediate_data(96 to 127)<= sbox_encoding_0(to_integer(unsigned(in_intermediate_data(96  to 103)))) xor
                                        sbox_encoding_1(to_integer(unsigned(in_intermediate_data(8   to  15)))) xor
                                        sbox_encoding_2(to_integer(unsigned(in_intermediate_data(48  to  55)))) xor
                                        sbox_encoding_3(to_integer(unsigned(in_intermediate_data(88  to  95)))) xor
                                        in_cipher_key(96 to 127);
    else
      out_intermediate_data_valid <= '0';
    end if;
  end if;
end process round;
  

end architecture arch_round_encoder;
