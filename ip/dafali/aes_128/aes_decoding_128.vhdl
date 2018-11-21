-------------------------------------------------------------------------------
-- Title      : aes decoding block for a 128 bit cipher key
-- Project    : AES IP core
-------------------------------------------------------------------------------
-- File       : aes_decoding_128.vhdl
-- Author     : Rachid DAFALI  
-- Company    : Personal project
-- Created    : 2012-11-21
-- Last update: 2018-11-18
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
-- 2012-11-21  1.0      rachid  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.aes_pkg.all;

entity aes_decoding_128 is
  
  port (
    in_clk                 : in  std_logic;
    in_reset               : in  std_logic;
    in_new_cipher_key      : in  std_logic;
    in_expanded_key_data   : in  std_logic_vector (0 to 127);
    in_expanded_key_valid  : in  std_logic;
    in_expanded_key_ready  : in  std_logic;
    out_expanded_key_start : out std_logic;
    out_plain_data         : out std_logic_vector(0 to 127);
    out_plain_data_valid   : out std_logic;
    in_cipher_data         : in  std_logic_vector(0 to 127);
    in_cipher_data_valid   : in  std_logic;
    out_ready              : out std_logic);

end entity aes_decoding_128;



architecture arch_aes_encoding_128 of aes_decoding_128 is

  signal cipher_key_table        : std_logic_vector_0_to_127_table_11_type;
  signal step                    : std_logic_vector(0 to 1) := "00";
  signal expansion_round         : integer                  := 0;
  signal intermediate_data       : std_logic_vector_0_to_127_table_10_type;
  signal intermediate_data_valid : std_logic_table_10_type;


begin

  round_0 : process (in_clk, in_reset, in_cipher_data_valid) is
  begin
    if in_reset = '0' then
      intermediate_data_valid(0) <= '0';
      intermediate_data(0)       <= X"00000000000000000000000000000000";
    elsif in_clk'event and in_clk = '1' then
      if in_cipher_data_valid = '1' then
        intermediate_data_valid(0)      <= '1';
        intermediate_data(0)(0 to 31)   <= in_cipher_data(0 to 31) xor cipher_key_table(0)(0 to 31);
        intermediate_data(0)(32 to 63)  <= in_cipher_data(32 to 63) xor cipher_key_table(0)(32 to 63);
        intermediate_data(0)(64 to 95)  <= in_cipher_data(64 to 95) xor cipher_key_table(0)(64 to 95);
        intermediate_data(0)(96 to 127) <= in_cipher_data(96 to 127) xor cipher_key_table(0)(96 to 127);
      else
        intermediate_data_valid(0) <= '0';
      end if;
    end if;
  end process round_0;

  round_from_1_to_9_generation : for I in 1 to 9 generate
    roundX : round_decoder
      port map (
        in_clk                      => in_clk,
        in_reset                    => in_reset,
        in_cipher_key               => cipher_key_table(I),
        in_intermediate_data        => intermediate_data(I-1),
        in_intermediate_data_valid  => intermediate_data_valid(I-1),
        out_intermediate_data       => intermediate_data(I),
        out_intermediate_data_valid => intermediate_data_valid(I));
  end generate round_from_1_to_9_generation;

  round_10 : process (in_clk, in_reset, intermediate_data_valid(9)) is
  begin
    if in_reset = '0' then
      out_plain_data_valid <= '0';
      out_plain_data       <= X"00000000000000000000000000000000";
    elsif in_clk'event and in_clk = '1' then
      if intermediate_data_valid(9) = '1' then
        out_plain_data_valid    <= '1';
        out_plain_data(0 to 31) <= (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(0 to 7)))) and X"FF000000") xor
                                   (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(104 to 111)))) and X"00FF0000") xor
                                   (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(80 to 87)))) and X"0000FF00") xor
                                   (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(56 to 63)))) and X"000000FF") xor
                                   cipher_key_table(10)(0 to 31);
        out_plain_data(32 to 63) <= (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(32 to 39)))) and X"FF000000") xor
                                    (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(8 to 15)))) and X"00FF0000") xor
                                    (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(112 to 119)))) and X"0000FF00") xor
                                    (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(88 to 95)))) and X"000000FF") xor
                                    cipher_key_table(10)(32 to 63);
        out_plain_data(64 to 95) <= (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(64 to 71)))) and X"FF000000") xor
                                    (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(40 to 47))))and X"00FF0000") xor
                                    (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(16 to 23)))) and X"0000FF00") xor
                                    (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(120 to 127)))) and X"000000FF") xor
                                    cipher_key_table(10)(64 to 95);
        out_plain_data(96 to 127) <= (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(96 to 103)))) and X"FF000000") xor
                                     (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(72 to 79)))) and X"00FF0000") xor
                                     (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(48 to 55)))) and X"0000FF00") xor
                                     (sbox_decoding_4(to_integer(unsigned(intermediate_data(9)(24 to 31)))) and X"000000FF") xor
                                     cipher_key_table(10)(96 to 127);
      else
        out_plain_data_valid <= '0';
      end if;
    end if;
  end process round_10;

  cipher_key_expansion_ctrl : process (in_clk, in_reset) is
  begin
    if in_reset = '0' then
      out_ready <= '1';
      step                   <= "00";
      expansion_round        <= 10;
      out_expanded_key_start <= '0';
    elsif in_clk'event and in_clk = '1' then

      if in_new_cipher_key = '1' and in_expanded_key_ready = '1' then
        out_ready <= '0';
        out_expanded_key_start <= '1';
        step                   <= "01";
      end if;

      if in_expanded_key_valid = '1' and step = "01" then
        
        cipher_key_table(expansion_round) <= in_expanded_key_data;
        if expansion_round = 0 then
          step <= "10";
        else
          expansion_round <= expansion_round - 1;
        end if;
      end if;

      if expansion_round < 9 and in_expanded_key_valid = '1' then
        cipher_key_table(expansion_round+1)(0 to 31) <=
          sbox_decoding_0(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(0 to 7)))) and X"000000FF")))) xor
          sbox_decoding_1(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(8 to 15)))) and X"000000FF")))) xor
          sbox_decoding_2(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(16 to 23)))) and X"000000FF")))) xor
          sbox_decoding_3(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(24 to 31)))) and X"000000FF"))));

        cipher_key_table(expansion_round+1)(32 to 63) <=
          sbox_decoding_0(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(32 to 39)))) and X"000000FF")))) xor
          sbox_decoding_1(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(40 to 47)))) and X"000000FF")))) xor
          sbox_decoding_2(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(48 to 55)))) and X"000000FF")))) xor
          sbox_decoding_3(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(56 to 63)))) and X"000000FF"))));

        cipher_key_table(expansion_round+1)(64 to 95) <=
          sbox_decoding_0(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(64 to 71)))) and X"000000FF")))) xor
          sbox_decoding_1(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(72 to 79)))) and X"000000FF")))) xor
          sbox_decoding_2(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(80 to 87)))) and X"000000FF")))) xor
          sbox_decoding_3(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(88 to 95)))) and X"000000FF"))));

        cipher_key_table(expansion_round+1)(96 to 127) <=
          sbox_decoding_0(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(96 to 103)))) and X"000000FF")))) xor
          sbox_decoding_1(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(104 to 111)))) and X"000000FF")))) xor
          sbox_decoding_2(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(112 to 119)))) and X"000000FF")))) xor
          sbox_decoding_3(to_integer(unsigned((sbox_encoding_4(to_integer(unsigned(cipher_key_table(expansion_round+1)(120 to 127)))) and X"000000FF"))));
      end if;

      case step is
        when "00" =>
          expansion_round        <= 10;
        when "01" =>
          out_expanded_key_start <= '0';
        when "10" =>
          out_ready <= '1';
          step                   <= "00";
        when others => null;
      end case;
    end if;

  end process cipher_key_expansion_ctrl;

end architecture arch_aes_encoding_128;
