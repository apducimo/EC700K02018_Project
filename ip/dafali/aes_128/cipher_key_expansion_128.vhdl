-------------------------------------------------------------------------------
-- Title      : 128 bit cipher key expantion
-- Project    : AES IP Core
-------------------------------------------------------------------------------
-- File       : cipher_key_expantion.vhdl
-- Author     : Rachid DAFALI  
-- Company    : personal project
-- Created    : 2012-11-21
-- Last update: 2012-11-21
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
-- 2012-11-21  1.0      rachid	Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.aes_pkg.all;

entity cipher_key_expansion_128 is
  
  port (
    in_clk              : in  std_logic;
    in_reset            : in  std_logic;
    in_cipher_key       : in  std_logic_vector(0 to 127);
    in_request          : in  std_logic;
    out_cipher_key      : out std_logic_vector(0 to 127);
    out_valid           : out std_logic;
    out_ready           : out std_logic);
end entity cipher_key_expansion_128;

architecture arch_cipher_key_expansion_128 of cipher_key_expansion_128 is

  signal ck_precedent_round : std_logic_vector(0 to 127) := X"00000000000000000000000000000000"; -- ck: cipher key
  signal ck_current_round : std_logic_vector(0 to 127) := X"00000000000000000000000000000000";
  signal round_counter : integer := 0;
  signal new_key_request : std_logic := '0';
  signal ready : std_logic := '1';

begin

  new_key: process (in_clk, in_reset) is
    variable step : integer := 0;
  begin 
    if in_reset = '0' then              
      round_counter <= 0;
      step := 0;
      out_valid <= '0';
      ck_precedent_round <=  X"00000000000000000000000000000000";
      ck_current_round <=  X"00000000000000000000000000000000";
    elsif in_clk'event and in_clk = '1' then 
      if new_key_request = '1' then
        case step is
          when 0 =>        
             if round_counter = 0 then
               out_cipher_key <= in_cipher_key;
               ck_precedent_round <= in_cipher_key;
               out_valid <= '1';
             else
               ck_precedent_round <= ck_current_round;
               out_valid <= '0';
             end if;
          when 1  =>
            if round_counter = 0 then
              out_valid <= '0';
            end if;
            ck_current_round(0 to 31) <= ck_precedent_round(0 to 31) xor
                                         (((sbox_encoding_4(to_integer(unsigned(ck_precedent_round(104 to 111))))) and X"FF000000") or
                                          ((sbox_encoding_4(to_integer(unsigned(ck_precedent_round(112 to 119))))) and X"00FF0000") or
                                          ((sbox_encoding_4(to_integer(unsigned(ck_precedent_round(120 to 127))))) and X"0000FF00") or
                                          ((sbox_encoding_4(to_integer(unsigned(ck_precedent_round(96  to 103))))) and X"000000FF")) xor
                                         rcon(round_counter);
          when 2  =>
            ck_current_round(32 to 63 ) <= ck_precedent_round(32 to 63 ) xor ck_current_round(0  to 31);
          when 3  =>
            ck_current_round(64 to 95 ) <= ck_precedent_round(64 to 95 ) xor ck_current_round(32 to 63);
          when 4  =>
            ck_current_round(96 to 127) <= ck_precedent_round(96 to 127) xor ck_current_round(64 to 95);
            round_counter <= round_counter + 1;           
          when 5 =>
            out_cipher_key <= ck_current_round;
            out_valid <= '1';
          when others => null;
        end case;
        if step = 5 then
          step := 0;
        else
          step := step + 1;
        end if;
      else
        round_counter <= 0;
        step :=0;
      end if;
    end if;
  end process new_key;

  controller: process (in_clk, in_reset) is
  begin  
    if in_reset = '0' then            
      ready <= '1';
      new_key_request <='0';
    elsif in_clk'event and in_clk = '1' then  
      if in_request = '1' and round_counter = 0 then
        ready <= '0';
      elsif round_counter = 10 then
        ready <= '1';
      end if;
        
      if ready = '0'  then
        new_key_request <= '1';
      else
        new_key_request <= '0';
      end if; 
      
    end if;
  end process controller;

  ready_process : out_ready <= ready;

end architecture arch_cipher_key_expansion_128;
