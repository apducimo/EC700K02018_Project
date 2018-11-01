-------------------------------------------------------------------------------
-- Title      : aes cipher block testbench 128 bits
-- Project    : AES IP Core
-------------------------------------------------------------------------------
-- File       : aes_cipher_block_128_TB.vhdl
-- Author     : Rachid DAFAL
-- Company    : 
-- Created    : 2012-11-22
-- Last update: 2012-11-26
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
-- 2012-11-22  1.0      rachid	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.aes_pkg.all;

entity aes_cipher_block_128_TB is
  
end entity aes_cipher_block_128_TB;

architecture arch_aes_cipher_block_128_TB of aes_cipher_block_128_TB is

  constant test_vector_length : integer := 6;
  constant cipher_key : std_logic_vector(0 to 127) := X"00000000000000000000000000000000";
  type test_vector_0_to_127 is array (0 to test_vector_length) of std_logic_vector(0 to 127);

  constant plain_data_table : test_vector_0_to_127 := (X"f34481ec3cc627bacd5dc3fb08f273e6",
                                                       X"9798c4640bad75c7c3227db910174e72",
                                                       X"96ab5c2ff612d9dfaae8c31f30c42168",
                                                       X"6a118a874519e64e9963798a503f1d35",
                                                       X"cb9fceec81286ca3e989bd979b0cb284",
                                                       X"b26aeb1874e47ca8358ff22378f09144",
                                                       X"58c8e00b2631686d54eab84b91f0aca1");

  constant cipher_data_table : test_vector_0_to_127 := (X"0336763e966d92595a567cc9ce537f5e",
                                                        X"a9a1631bf4996954ebc093957b234589",
                                                        X"ff4f8391a6a40ca5b25d23bedd44a597",
                                                        X"dc43be40be0e53712f7e2bf5ca707209",
                                                        X"92beedab1895a94faa69b632e5cc47ce",
                                                        X"459264f4798f6a78bacb89c15ed3d601",
                                                        X"08a4e2efec8a8e3312ca7460b9040bbf");
  constant tpw_clk : time := 10 ns;
 
  signal clk_TB : std_logic;
  signal reset_TB : std_logic;
  signal cipher_key_TB : std_logic_vector(0 to 127);
  signal cipher_key_valid_to_encoder_TB : std_logic;
  signal cipher_key_valid_to_decoder_TB : std_logic;
  signal out_plain_data_TB : std_logic_vector(0 to 127);
  signal out_plain_data_valid_TB : std_logic;
  signal in_cipher_data_TB : std_logic_vector(0 to 127);
  signal in_cipher_data_valid_TB : std_logic;
  signal in_plain_data_TB : std_logic_vector(0 to 127);
  signal in_plain_data_valid_TB : std_logic;
  signal out_cipher_data_TB : std_logic_vector(0 to 127);
  signal out_cipher_data_valid_TB : std_logic;
  signal ready_decoder_TB, ready_encoder_TB : std_logic;

  signal step : integer := 0;
  
begin

  aes_cipher_block_128_inst : aes_cipher_block_128
    port map (
      in_clk                            => clk_TB,
      in_reset                          => reset_TB,
      in_cipher_key                     => cipher_key_TB,
      in_cipher_key_valid_to_encoder    => cipher_key_valid_to_encoder_TB,
      in_cipher_key_valid_to_decoder    => cipher_key_valid_to_decoder_TB,
      out_plain_data                    => out_plain_data_TB,
      out_plain_data_valid              => out_plain_data_valid_TB,
      in_cipher_data                    => in_cipher_data_TB,
      in_cipher_data_valid              => in_cipher_data_valid_TB,
      in_plain_data                     => in_plain_data_TB,
      in_plain_data_valid               => in_plain_data_valid_TB,
      out_cipher_data                   => out_cipher_data_TB,
      out_cipher_data_valid             => out_cipher_data_valid_TB,
      out_decoder_ready                  => ready_decoder_TB,
      out_encoder_ready                 => ready_encoder_TB );
  
  clk_TB_generation: process 
  begin  
    for i in 0 to 2000 loop
      clk_TB <= '0';
      wait for tpw_clk;
      clk_TB <= '1';
      wait for tpw_clk;
    end loop;  
    wait;
  end process clk_TB_generation;

  
  result_validation: process (clk_TB, reset_TB) is
    variable table_counter,table_counter_2 : integer := 0;
  begin 
    if reset_TB = '0' then              
      step <= 0;
      table_counter := 0;
    elsif clk_TB'event and clk_TB = '1' then  
       if out_cipher_data_valid_TB = '1' and  out_cipher_data_TB = cipher_data_table(table_counter) then
         report "Successful encoding from the vector " & integer'image(table_counter) & " of the plaintext table" severity note;
         if table_counter = test_vector_length then
           table_counter := 0;
         else
           table_counter := table_counter + 1;
         end if;
         step <= step + 1;
       elsif out_cipher_data_valid_TB = '1' and out_cipher_data_TB /= cipher_data_table(table_counter) then
         report "Error encoding from the vector " & integer'image(table_counter) & " of the plaintext table" severity error;
          if table_counter = test_vector_length then
           table_counter := 0;
         else
           table_counter := table_counter + 1;
         end if;
         step <= step + 1;
       end if;
       if out_plain_data_valid_TB = '1' and  out_plain_data_TB = plain_data_table(table_counter_2) then
         report "Successful decoding from the vector " & integer'image(table_counter_2) & " of the ciphertext table" severity note;
         step <= step + 1;
         if table_counter_2 = test_vector_length then
           table_counter_2 := 0;
         else
           table_counter_2 := table_counter_2 + 1;
         end if;
       elsif out_plain_data_valid_TB = '1' and out_plain_data_TB /= plain_data_table(table_counter_2) then
         report "Error decoding from the vector " & integer'image(table_counter_2) & " of the ciphertext table"  severity error;
         step <= step + 1;
          if table_counter_2 = test_vector_length then
           table_counter_2 := 0;
         else
           table_counter_2 := table_counter_2 + 1;
         end if;
      end if;
    end if;
  end process result_validation;

  testbench_clrl: process is
  begin      
    wait for 10*tpw_clk;
    report "==== First test : encrypting data only (Key expansion included) ====" severity note;
    cipher_key_valid_to_encoder_TB <= '1';
    cipher_key_TB <= cipher_key;
    wait for 2*tpw_clk;
    cipher_key_valid_to_encoder_TB <= '0';
    in_plain_data_valid_TB <= '0';
    wait for 150*tpw_clk;
    for i in 0 to test_vector_length loop
      in_plain_data_TB <= plain_data_table(i);
      in_plain_data_valid_TB <= '1';
      wait for 2*tpw_clk;
      in_plain_data_valid_TB <= '0';
    end loop;  -- i
    
    wait for 150*tpw_clk;
    report "==== Second test decrypting data only (Key expansion included) ====" severity note;
    cipher_key_valid_to_decoder_TB <= '1';
    cipher_key_TB <= cipher_key;
    wait for 2*tpw_clk;
    cipher_key_valid_to_decoder_TB <= '0';
    in_cipher_data_valid_TB <= '0';
    wait for 150*tpw_clk;
     for j in 0 to test_vector_length loop
       in_cipher_data_TB <= cipher_data_table(j);
       in_cipher_data_valid_TB <= '1';
       wait for 2*tpw_clk;
       in_cipher_data_valid_TB <= '0';
    end loop;  -- i
    

     wait for 150*tpw_clk;
    report "==== Third test : encrypting and decrypting simultaneously (key expansion included) ====" severity note;
    cipher_key_valid_to_decoder_TB <= '1';
    cipher_key_valid_to_encoder_TB <= '1';
    cipher_key_TB <= cipher_key;
    wait for 2*tpw_clk;
    cipher_key_valid_to_decoder_TB <= '0';
    cipher_key_valid_to_encoder_TB <= '0';
    in_cipher_data_valid_TB <= '0';
    in_plain_data_valid_TB <= '0';
    wait for 150*tpw_clk;
    wait for 150*tpw_clk;
     for k in 0 to test_vector_length loop
       in_plain_data_TB <= plain_data_table(k);
       in_plain_data_valid_TB <= '1';
       in_cipher_data_TB <= cipher_data_table(k);
       in_cipher_data_valid_TB <= '1';
       wait for 2*tpw_clk;
       in_cipher_data_valid_TB <= '0';
       in_plain_data_valid_TB <= '0';
    end loop;  -- i
    
    
    
    wait;
  end process  testbench_clrl;

  reset_TB_generation: process is
  begin 
    wait for 2*tpw_clk;
    reset_TB <= '1';
    wait for 2*tpw_clk;
    reset_TB <= '0';
    wait for 2*tpw_clk;
    reset_TB <= '1';
    wait;
  end process reset_TB_generation;

end architecture arch_aes_cipher_block_128_TB;
