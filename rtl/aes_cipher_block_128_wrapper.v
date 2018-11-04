module aes_cipher_block_128_wrapper (
  in_clk,
  in_reset,  
  in_cipher_key,
  in_cipher_key_valid_to_encoder,
  in_cipher_key_valid_to_decoder,
  out_plain_data,
  out_plain_data_valid,
  in_cipher_data,
  in_cipher_data_valid,
  in_plain_data,
  in_plain_data_valid,
  out_cipher_data,
  out_cipher_data_valid,
  out_decoder_ready,
  out_encoder_ready
);
  input          in_clk;
  input          in_reset;  
  input  [127:0] in_cipher_key;
  input          in_cipher_key_valid_to_encoder;
  input          in_cipher_key_valid_to_decoder;
  output [127:0] out_plain_data;
  output         out_plain_data_valid;
  input  [127:0] in_cipher_data;
  input          in_cipher_data_valid;
  input  [127:0] in_plain_data;
  input          in_plain_data_valid;
  output [127:0] out_cipher_data;
  output         out_cipher_data_valid;
  output         out_decoder_ready;
  output         out_encoder_ready;

  aes_cipher_block_128 u_aes_cipher_block_128 (
    .in_clk                         (in_clk),
    .in_reset                       (in_reset),  
    .in_cipher_key                  (in_cipher_key),
    .in_cipher_key_valid_to_encoder (in_cipher_key_valid_to_encoder),
    .in_cipher_key_valid_to_decoder (in_cipher_key_valid_to_decoder),
    .out_plain_data                 (out_plain_data),
    .out_plain_data_valid           (out_plain_data_valid),
    .in_cipher_data                 (in_cipher_data),
    .in_cipher_data_valid           (in_cipher_data_valid),
    .in_plain_data                  (in_plain_data),
    .in_plain_data_valid            (in_plain_data_valid),
    .out_cipher_data                (out_cipher_data),
    .out_cipher_data_valid          (out_cipher_data_valid),
    .out_decoder_ready              (out_decoder_ready),
    .out_encoder_ready              (out_encoder_ready)
  );

endmodule
  