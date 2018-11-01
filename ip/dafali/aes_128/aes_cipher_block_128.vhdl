-------------------------------------------------------------------------------
-- Title      : aes cipher block (128 bits)
-- Project    : AES IP Core
-------------------------------------------------------------------------------
-- File       : aes_cipher_block_128.vhdl
-- Author     : Rachid DAFALI 
-- Company    : 
-- Created    : 2012-11-22
-- Last update: 2012-11-28
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

entity aes_cipher_block_128 is
  
  port (
    in_clk                              : in  std_logic;
    in_reset                            : in  std_logic;  
    in_cipher_key                       : in  std_logic_vector(0 to 127);
    in_cipher_key_valid_to_encoder    : in  std_logic;
    in_cipher_key_valid_to_decoder    : in  std_logic;
    out_plain_data                      : out  std_logic_vector(0 to 127);
    out_plain_data_valid                : out  std_logic;
    in_cipher_data                      : in std_logic_vector(0 to 127);
    in_cipher_data_valid                : in std_logic;
    in_plain_data                       : in  std_logic_vector(0 to 127);
    in_plain_data_valid                 : in  std_logic;
    out_cipher_data                     : out std_logic_vector(0 to 127);
    out_cipher_data_valid               : out std_logic;
    out_decoder_ready                   : out std_logic;
    out_encoder_ready                   : out std_logic);

end entity aes_cipher_block_128;

architecture arch_aes_cipher_block_128 of aes_cipher_block_128 is

  

  signal expansion_key_start                    : std_logic;
  signal expansion_key_start_form_encoder       : std_logic;
  signal expansion_key_start_form_decoder       : std_logic;
  signal expanded_key_data                      : std_logic_vector(0 to 127);
  signal expanded_key_data_to_encoder           : std_logic_vector(0 to 127);
  signal expanded_key_data_to_decoder           : std_logic_vector(0 to 127);
  signal expanded_key_valid                     : std_logic;
  signal expanded_key_valid_to_encoder          : std_logic;
  signal expanded_key_valid_to_decoder          : std_logic;
  signal expanded_key_ready                     : std_logic;
  signal expansion_result_to_encoder            : std_logic := '0';
  signal expansion_result_to_encoder_bis        : std_logic := '0';
  signal expansion_result_to_decoder            : std_logic := '0';
  signal expansion_result_to_decoder_bis        : std_logic := '0';
  
begin  

  aes_encoding_block : aes_encoding_128
    port map (
      in_clk                    => in_clk,
      in_reset                  => in_reset,
      in_new_cipher_key         => in_cipher_key_valid_to_encoder,
      in_expanded_key_data      => expanded_key_data_to_encoder,
      in_expanded_key_valid     => expanded_key_valid_to_encoder ,
      in_expanded_key_ready     =>  expanded_key_ready,
      out_expanded_key_start    => expansion_key_start_form_encoder,
      in_plain_data             => in_plain_data,
      in_plain_data_valid       => in_plain_data_valid,
      out_cipher_data           => out_cipher_data,
      out_cipher_data_valid     => out_cipher_data_valid,
      out_ready                 => out_encoder_ready);
  
  aes_decoding_block : aes_decoding_128
    port map (
      in_clk                    => in_clk,
      in_reset                  => in_reset,
      in_new_cipher_key         => in_cipher_key_valid_to_decoder,
      in_expanded_key_data      => expanded_key_data_to_decoder,
      in_expanded_key_valid     => expanded_key_valid_to_decoder ,
      in_expanded_key_ready     =>  expanded_key_ready,
      out_expanded_key_start    => expansion_key_start_form_decoder,
      out_plain_data            => out_plain_data,
      out_plain_data_valid      => out_plain_data_valid,
      in_cipher_data            => in_cipher_data,
      in_cipher_data_valid      => in_cipher_data_valid,
      out_ready                 => out_decoder_ready);
     
  cipher_key_expansion_block : cipher_key_expansion_128
    port map (
      in_clk             => in_clk,
      in_reset           => in_reset,
      in_cipher_key      => in_cipher_key,
      in_request         => expansion_key_start,
      out_cipher_key     => expanded_key_data,
      out_valid          => expanded_key_valid,
      out_ready          => expanded_key_ready);

  expansion_key_start <= expansion_key_start_form_decoder or expansion_key_start_form_encoder
                         when expanded_key_ready = '1' else '0';
  
  expanded_key_data_to_encoder <= expanded_key_data when expansion_result_to_encoder ='1' else X"00000000000000000000000000000000";
  expanded_key_data_to_decoder <= expanded_key_data when expansion_result_to_decoder ='1' else X"00000000000000000000000000000000";

  expanded_key_valid_to_encoder <= expanded_key_valid when expansion_result_to_encoder ='1' else '0';
  expanded_key_valid_to_decoder <= expanded_key_valid when expansion_result_to_decoder ='1' else '0';

  expansion_key_transmission_ctrl: process (in_clk, in_reset, in_cipher_key_valid_to_encoder, in_cipher_key_valid_to_decoder) is
  begin  
    if in_reset = '0' then              
      expansion_result_to_encoder <= '0';
      expansion_result_to_decoder <= '0';
      expansion_result_to_encoder_bis <= '0';
      expansion_result_to_encoder_bis <= '0';
    elsif in_clk'event and in_clk = '1' then  

      if in_cipher_key_valid_to_encoder = '1' then
        expansion_result_to_encoder_bis <= '1';
      elsif expanded_key_ready ='1' and expansion_result_to_encoder = '1' then
        expansion_result_to_encoder_bis <= '0';
      end if;
      
      if expansion_result_to_encoder_bis = '1' then
        expansion_result_to_encoder <= '1'; 
      elsif expanded_key_ready = '1' then
        expansion_result_to_encoder <= '0';
      end if;

      if in_cipher_key_valid_to_decoder = '1' then
        expansion_result_to_decoder_bis <= '1';
      elsif expanded_key_ready = '1' and expansion_result_to_decoder = '1' then
        expansion_result_to_decoder_bis <= '0';
      end if;

      if expansion_result_to_decoder_bis = '1' then
        expansion_result_to_decoder <= '1';
      elsif expanded_key_ready = '1' then
        expansion_result_to_decoder <= '0';
      end if;
      
    end if;
  end process expansion_key_transmission_ctrl;
end architecture arch_aes_cipher_block_128;
