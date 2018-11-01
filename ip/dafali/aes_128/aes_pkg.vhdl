-------------------------------------------------------------------------------
-- Title      : AES package
-- Project    : AES IP CORE
-------------------------------------------------------------------------------
-- File       : aes_pkg.vhdl
-- Author     : Rachid DAFALI  
-- Company    : 
-- Created    : 2012-11-15
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
-- 2012-11-15  1.0      rachid	Created
------------------------------------1-------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package aes_pkg is


 type std_logic_vector_0_to_127_table_11_type is array (0 to 10) of std_logic_vector(0 to 127);
 type std_logic_vector_0_to_127_table_10_type is array (0 to 9) of std_logic_vector(0 to 127);
 type std_logic_table_10_type is array (0 to 9) of std_logic;
  
 type substitution_box_type is array (0 to 255) of std_logic_vector(0 to 31);

 constant sbox_encoding_0 : substitution_box_type := (
   X"c66363a5", X"f87c7c84", X"ee777799", X"f67b7b8d", X"fff2f20d", X"d66b6bbd", X"de6f6fb1", X"91c5c554", X"60303050", X"02010103",
   X"ce6767a9", X"562b2b7d", X"e7fefe19", X"b5d7d762", X"4dababe6", X"ec76769a", X"8fcaca45", X"1f82829d", X"89c9c940", X"fa7d7d87",
   X"effafa15", X"b25959eb", X"8e4747c9", X"fbf0f00b", X"41adadec", X"b3d4d467", X"5fa2a2fd", X"45afafea", X"239c9cbf", X"53a4a4f7",
   X"e4727296", X"9bc0c05b", X"75b7b7c2", X"e1fdfd1c", X"3d9393ae", X"4c26266a", X"6c36365a", X"7e3f3f41", X"f5f7f702", X"83cccc4f",
   X"6834345c", X"51a5a5f4", X"d1e5e534", X"f9f1f108", X"e2717193", X"abd8d873", X"62313153", X"2a15153f", X"0804040c", X"95c7c752",
   X"46232365", X"9dc3c35e", X"30181828", X"379696a1", X"0a05050f", X"2f9a9ab5", X"0e070709", X"24121236", X"1b80809b", X"dfe2e23d",
   X"cdebeb26", X"4e272769", X"7fb2b2cd", X"ea75759f", X"1209091b", X"1d83839e", X"582c2c74", X"341a1a2e", X"361b1b2d", X"dc6e6eb2",
   X"b45a5aee", X"5ba0a0fb", X"a45252f6", X"763b3b4d", X"b7d6d661", X"7db3b3ce", X"5229297b", X"dde3e33e", X"5e2f2f71", X"13848497",
   X"a65353f5", X"b9d1d168", X"00000000", X"c1eded2c", X"40202060", X"e3fcfc1f", X"79b1b1c8", X"b65b5bed", X"d46a6abe", X"8dcbcb46",
   X"67bebed9", X"7239394b", X"944a4ade", X"984c4cd4", X"b05858e8", X"85cfcf4a", X"bbd0d06b", X"c5efef2a", X"4faaaae5", X"edfbfb16",
   X"864343c5", X"9a4d4dd7", X"66333355", X"11858594", X"8a4545cf", X"e9f9f910", X"04020206", X"fe7f7f81", X"a05050f0", X"783c3c44",
   X"259f9fba", X"4ba8a8e3", X"a25151f3", X"5da3a3fe", X"804040c0", X"058f8f8a", X"3f9292ad", X"219d9dbc", X"70383848", X"f1f5f504",
   X"63bcbcdf", X"77b6b6c1", X"afdada75", X"42212163", X"20101030", X"e5ffff1a", X"fdf3f30e", X"bfd2d26d", X"81cdcd4c", X"180c0c14",
   X"26131335", X"c3ecec2f", X"be5f5fe1", X"359797a2", X"884444cc", X"2e171739", X"93c4c457", X"55a7a7f2", X"fc7e7e82", X"7a3d3d47",
   X"c86464ac", X"ba5d5de7", X"3219192b", X"e6737395", X"c06060a0", X"19818198", X"9e4f4fd1", X"a3dcdc7f", X"44222266", X"542a2a7e",
   X"3b9090ab", X"0b888883", X"8c4646ca", X"c7eeee29", X"6bb8b8d3", X"2814143c", X"a7dede79", X"bc5e5ee2", X"160b0b1d", X"addbdb76",
   X"dbe0e03b", X"64323256", X"743a3a4e", X"140a0a1e", X"924949db", X"0c06060a", X"4824246c", X"b85c5ce4", X"9fc2c25d", X"bdd3d36e",
   X"43acacef", X"c46262a6", X"399191a8", X"319595a4", X"d3e4e437", X"f279798b", X"d5e7e732", X"8bc8c843", X"6e373759", X"da6d6db7",
   X"018d8d8c", X"b1d5d564", X"9c4e4ed2", X"49a9a9e0", X"d86c6cb4", X"ac5656fa", X"f3f4f407", X"cfeaea25", X"ca6565af", X"f47a7a8e",
   X"47aeaee9", X"10080818", X"6fbabad5", X"f0787888", X"4a25256f", X"5c2e2e72", X"381c1c24", X"57a6a6f1", X"73b4b4c7", X"97c6c651",
   X"cbe8e823", X"a1dddd7c", X"e874749c", X"3e1f1f21", X"964b4bdd", X"61bdbddc", X"0d8b8b86", X"0f8a8a85", X"e0707090", X"7c3e3e42",
   X"71b5b5c4", X"cc6666aa", X"904848d8", X"06030305", X"f7f6f601", X"1c0e0e12", X"c26161a3", X"6a35355f", X"ae5757f9", X"69b9b9d0",
   X"17868691", X"99c1c158", X"3a1d1d27", X"279e9eb9", X"d9e1e138", X"ebf8f813", X"2b9898b3", X"22111133", X"d26969bb", X"a9d9d970",
   X"078e8e89", X"339494a7", X"2d9b9bb6", X"3c1e1e22", X"15878792", X"c9e9e920", X"87cece49", X"aa5555ff", X"50282878", X"a5dfdf7a",
   X"038c8c8f", X"59a1a1f8", X"09898980", X"1a0d0d17", X"65bfbfda", X"d7e6e631", X"844242c6", X"d06868b8", X"824141c3", X"299999b0",
   X"5a2d2d77", X"1e0f0f11", X"7bb0b0cb", X"a85454fc", X"6dbbbbd6", X"2c16163a");

 constant sbox_encoding_1 : substitution_box_type := (                                                
   X"a5c66363", X"84f87c7c", X"99ee7777", X"8df67b7b", X"0dfff2f2", X"bdd66b6b", X"b1de6f6f", X"5491c5c5", X"50603030", X"03020101",
   X"a9ce6767", X"7d562b2b", X"19e7fefe", X"62b5d7d7", X"e64dabab", X"9aec7676", X"458fcaca", X"9d1f8282", X"4089c9c9", X"87fa7d7d",
   X"15effafa", X"ebb25959", X"c98e4747", X"0bfbf0f0", X"ec41adad", X"67b3d4d4", X"fd5fa2a2", X"ea45afaf", X"bf239c9c", X"f753a4a4",
   X"96e47272", X"5b9bc0c0", X"c275b7b7", X"1ce1fdfd", X"ae3d9393", X"6a4c2626", X"5a6c3636", X"417e3f3f", X"02f5f7f7", X"4f83cccc",
   X"5c683434", X"f451a5a5", X"34d1e5e5", X"08f9f1f1", X"93e27171", X"73abd8d8", X"53623131", X"3f2a1515", X"0c080404", X"5295c7c7",
   X"65462323", X"5e9dc3c3", X"28301818", X"a1379696", X"0f0a0505", X"b52f9a9a", X"090e0707", X"36241212", X"9b1b8080", X"3ddfe2e2",
   X"26cdebeb", X"694e2727", X"cd7fb2b2", X"9fea7575", X"1b120909", X"9e1d8383", X"74582c2c", X"2e341a1a", X"2d361b1b", X"b2dc6e6e",
   X"eeb45a5a", X"fb5ba0a0", X"f6a45252", X"4d763b3b", X"61b7d6d6", X"ce7db3b3", X"7b522929", X"3edde3e3", X"715e2f2f", X"97138484",
   X"f5a65353", X"68b9d1d1", X"00000000", X"2cc1eded", X"60402020", X"1fe3fcfc", X"c879b1b1", X"edb65b5b", X"bed46a6a", X"468dcbcb",
   X"d967bebe", X"4b723939", X"de944a4a", X"d4984c4c", X"e8b05858", X"4a85cfcf", X"6bbbd0d0", X"2ac5efef", X"e54faaaa", X"16edfbfb",
   X"c5864343", X"d79a4d4d", X"55663333", X"94118585", X"cf8a4545", X"10e9f9f9", X"06040202", X"81fe7f7f", X"f0a05050", X"44783c3c",
   X"ba259f9f", X"e34ba8a8", X"f3a25151", X"fe5da3a3", X"c0804040", X"8a058f8f", X"ad3f9292", X"bc219d9d", X"48703838", X"04f1f5f5",
   X"df63bcbc", X"c177b6b6", X"75afdada", X"63422121", X"30201010", X"1ae5ffff", X"0efdf3f3", X"6dbfd2d2", X"4c81cdcd", X"14180c0c",
   X"35261313", X"2fc3ecec", X"e1be5f5f", X"a2359797", X"cc884444", X"392e1717", X"5793c4c4", X"f255a7a7", X"82fc7e7e", X"477a3d3d",
   X"acc86464", X"e7ba5d5d", X"2b321919", X"95e67373", X"a0c06060", X"98198181", X"d19e4f4f", X"7fa3dcdc", X"66442222", X"7e542a2a",
   X"ab3b9090", X"830b8888", X"ca8c4646", X"29c7eeee", X"d36bb8b8", X"3c281414", X"79a7dede", X"e2bc5e5e", X"1d160b0b", X"76addbdb",
   X"3bdbe0e0", X"56643232", X"4e743a3a", X"1e140a0a", X"db924949", X"0a0c0606", X"6c482424", X"e4b85c5c", X"5d9fc2c2", X"6ebdd3d3",
   X"ef43acac", X"a6c46262", X"a8399191", X"a4319595", X"37d3e4e4", X"8bf27979", X"32d5e7e7", X"438bc8c8", X"596e3737", X"b7da6d6d",
   X"8c018d8d", X"64b1d5d5", X"d29c4e4e", X"e049a9a9", X"b4d86c6c", X"faac5656", X"07f3f4f4", X"25cfeaea", X"afca6565", X"8ef47a7a",
   X"e947aeae", X"18100808", X"d56fbaba", X"88f07878", X"6f4a2525", X"725c2e2e", X"24381c1c", X"f157a6a6", X"c773b4b4", X"5197c6c6",
   X"23cbe8e8", X"7ca1dddd", X"9ce87474", X"213e1f1f", X"dd964b4b", X"dc61bdbd", X"860d8b8b", X"850f8a8a", X"90e07070", X"427c3e3e",
   X"c471b5b5", X"aacc6666", X"d8904848", X"05060303", X"01f7f6f6", X"121c0e0e", X"a3c26161", X"5f6a3535", X"f9ae5757", X"d069b9b9",
   X"91178686", X"5899c1c1", X"273a1d1d", X"b9279e9e", X"38d9e1e1", X"13ebf8f8", X"b32b9898", X"33221111", X"bbd26969", X"70a9d9d9",
   X"89078e8e", X"a7339494", X"b62d9b9b", X"223c1e1e", X"92158787", X"20c9e9e9", X"4987cece", X"ffaa5555", X"78502828", X"7aa5dfdf",
   X"8f038c8c", X"f859a1a1", X"80098989", X"171a0d0d", X"da65bfbf", X"31d7e6e6", X"c6844242", X"b8d06868", X"c3824141", X"b0299999",
   X"775a2d2d", X"111e0f0f", X"cb7bb0b0", X"fca85454", X"d66dbbbb", X"3a2c1616");

 constant sbox_encoding_2 : substitution_box_type := (
   X"63a5c663", X"7c84f87c", X"7799ee77", X"7b8df67b", X"f20dfff2", X"6bbdd66b", X"6fb1de6f", X"c55491c5", X"30506030", X"01030201",
   X"67a9ce67", X"2b7d562b", X"fe19e7fe", X"d762b5d7", X"abe64dab", X"769aec76", X"ca458fca", X"829d1f82", X"c94089c9", X"7d87fa7d",
   X"fa15effa", X"59ebb259", X"47c98e47", X"f00bfbf0", X"adec41ad", X"d467b3d4", X"a2fd5fa2", X"afea45af", X"9cbf239c", X"a4f753a4",
   X"7296e472", X"c05b9bc0", X"b7c275b7", X"fd1ce1fd", X"93ae3d93", X"266a4c26", X"365a6c36", X"3f417e3f", X"f702f5f7", X"cc4f83cc",
   X"345c6834", X"a5f451a5", X"e534d1e5", X"f108f9f1", X"7193e271", X"d873abd8", X"31536231", X"153f2a15", X"040c0804", X"c75295c7",
   X"23654623", X"c35e9dc3", X"18283018", X"96a13796", X"050f0a05", X"9ab52f9a", X"07090e07", X"12362412", X"809b1b80", X"e23ddfe2",
   X"eb26cdeb", X"27694e27", X"b2cd7fb2", X"759fea75", X"091b1209", X"839e1d83", X"2c74582c", X"1a2e341a", X"1b2d361b", X"6eb2dc6e",
   X"5aeeb45a", X"a0fb5ba0", X"52f6a452", X"3b4d763b", X"d661b7d6", X"b3ce7db3", X"297b5229", X"e33edde3", X"2f715e2f", X"84971384",
   X"53f5a653", X"d168b9d1", X"00000000", X"ed2cc1ed", X"20604020", X"fc1fe3fc", X"b1c879b1", X"5bedb65b", X"6abed46a", X"cb468dcb",
   X"bed967be", X"394b7239", X"4ade944a", X"4cd4984c", X"58e8b058", X"cf4a85cf", X"d06bbbd0", X"ef2ac5ef", X"aae54faa", X"fb16edfb",
   X"43c58643", X"4dd79a4d", X"33556633", X"85941185", X"45cf8a45", X"f910e9f9", X"02060402", X"7f81fe7f", X"50f0a050", X"3c44783c",
   X"9fba259f", X"a8e34ba8", X"51f3a251", X"a3fe5da3", X"40c08040", X"8f8a058f", X"92ad3f92", X"9dbc219d", X"38487038", X"f504f1f5",
   X"bcdf63bc", X"b6c177b6", X"da75afda", X"21634221", X"10302010", X"ff1ae5ff", X"f30efdf3", X"d26dbfd2", X"cd4c81cd", X"0c14180c",
   X"13352613", X"ec2fc3ec", X"5fe1be5f", X"97a23597", X"44cc8844", X"17392e17", X"c45793c4", X"a7f255a7", X"7e82fc7e", X"3d477a3d",
   X"64acc864", X"5de7ba5d", X"192b3219", X"7395e673", X"60a0c060", X"81981981", X"4fd19e4f", X"dc7fa3dc", X"22664422", X"2a7e542a",
   X"90ab3b90", X"88830b88", X"46ca8c46", X"ee29c7ee", X"b8d36bb8", X"143c2814", X"de79a7de", X"5ee2bc5e", X"0b1d160b", X"db76addb",
   X"e03bdbe0", X"32566432", X"3a4e743a", X"0a1e140a", X"49db9249", X"060a0c06", X"246c4824", X"5ce4b85c", X"c25d9fc2", X"d36ebdd3",
   X"acef43ac", X"62a6c462", X"91a83991", X"95a43195", X"e437d3e4", X"798bf279", X"e732d5e7", X"c8438bc8", X"37596e37", X"6db7da6d",
   X"8d8c018d", X"d564b1d5", X"4ed29c4e", X"a9e049a9", X"6cb4d86c", X"56faac56", X"f407f3f4", X"ea25cfea", X"65afca65", X"7a8ef47a",
   X"aee947ae", X"08181008", X"bad56fba", X"7888f078", X"256f4a25", X"2e725c2e", X"1c24381c", X"a6f157a6", X"b4c773b4", X"c65197c6",
   X"e823cbe8", X"dd7ca1dd", X"749ce874", X"1f213e1f", X"4bdd964b", X"bddc61bd", X"8b860d8b", X"8a850f8a", X"7090e070", X"3e427c3e",
   X"b5c471b5", X"66aacc66", X"48d89048", X"03050603", X"f601f7f6", X"0e121c0e", X"61a3c261", X"355f6a35", X"57f9ae57", X"b9d069b9",
   X"86911786", X"c15899c1", X"1d273a1d", X"9eb9279e", X"e138d9e1", X"f813ebf8", X"98b32b98", X"11332211", X"69bbd269", X"d970a9d9",
   X"8e89078e", X"94a73394", X"9bb62d9b", X"1e223c1e", X"87921587", X"e920c9e9", X"ce4987ce", X"55ffaa55", X"28785028", X"df7aa5df",
   X"8c8f038c", X"a1f859a1", X"89800989", X"0d171a0d", X"bfda65bf", X"e631d7e6", X"42c68442", X"68b8d068", X"41c38241", X"99b02999",
   X"2d775a2d", X"0f111e0f", X"b0cb7bb0", X"54fca854", X"bbd66dbb", X"163a2c16");

 constant sbox_encoding_3 : substitution_box_type := (
   X"6363a5c6", X"7c7c84f8", X"777799ee", X"7b7b8df6", X"f2f20dff", X"6b6bbdd6", X"6f6fb1de", X"c5c55491", X"30305060", X"01010302",
   X"6767a9ce", X"2b2b7d56", X"fefe19e7", X"d7d762b5", X"ababe64d", X"76769aec", X"caca458f", X"82829d1f", X"c9c94089", X"7d7d87fa",
   X"fafa15ef", X"5959ebb2", X"4747c98e", X"f0f00bfb", X"adadec41", X"d4d467b3", X"a2a2fd5f", X"afafea45", X"9c9cbf23", X"a4a4f753",
   X"727296e4", X"c0c05b9b", X"b7b7c275", X"fdfd1ce1", X"9393ae3d", X"26266a4c", X"36365a6c", X"3f3f417e", X"f7f702f5", X"cccc4f83",
   X"34345c68", X"a5a5f451", X"e5e534d1", X"f1f108f9", X"717193e2", X"d8d873ab", X"31315362", X"15153f2a", X"04040c08", X"c7c75295",
   X"23236546", X"c3c35e9d", X"18182830", X"9696a137", X"05050f0a", X"9a9ab52f", X"0707090e", X"12123624", X"80809b1b", X"e2e23ddf",
   X"ebeb26cd", X"2727694e", X"b2b2cd7f", X"75759fea", X"09091b12", X"83839e1d", X"2c2c7458", X"1a1a2e34", X"1b1b2d36", X"6e6eb2dc",
   X"5a5aeeb4", X"a0a0fb5b", X"5252f6a4", X"3b3b4d76", X"d6d661b7", X"b3b3ce7d", X"29297b52", X"e3e33edd", X"2f2f715e", X"84849713",
   X"5353f5a6", X"d1d168b9", X"00000000", X"eded2cc1", X"20206040", X"fcfc1fe3", X"b1b1c879", X"5b5bedb6", X"6a6abed4", X"cbcb468d",
   X"bebed967", X"39394b72", X"4a4ade94", X"4c4cd498", X"5858e8b0", X"cfcf4a85", X"d0d06bbb", X"efef2ac5", X"aaaae54f", X"fbfb16ed",
   X"4343c586", X"4d4dd79a", X"33335566", X"85859411", X"4545cf8a", X"f9f910e9", X"02020604", X"7f7f81fe", X"5050f0a0", X"3c3c4478",
   X"9f9fba25", X"a8a8e34b", X"5151f3a2", X"a3a3fe5d", X"4040c080", X"8f8f8a05", X"9292ad3f", X"9d9dbc21", X"38384870", X"f5f504f1",
   X"bcbcdf63", X"b6b6c177", X"dada75af", X"21216342", X"10103020", X"ffff1ae5", X"f3f30efd", X"d2d26dbf", X"cdcd4c81", X"0c0c1418",
   X"13133526", X"ecec2fc3", X"5f5fe1be", X"9797a235", X"4444cc88", X"1717392e", X"c4c45793", X"a7a7f255", X"7e7e82fc", X"3d3d477a",
   X"6464acc8", X"5d5de7ba", X"19192b32", X"737395e6", X"6060a0c0", X"81819819", X"4f4fd19e", X"dcdc7fa3", X"22226644", X"2a2a7e54",
   X"9090ab3b", X"8888830b", X"4646ca8c", X"eeee29c7", X"b8b8d36b", X"14143c28", X"dede79a7", X"5e5ee2bc", X"0b0b1d16", X"dbdb76ad",
   X"e0e03bdb", X"32325664", X"3a3a4e74", X"0a0a1e14", X"4949db92", X"06060a0c", X"24246c48", X"5c5ce4b8", X"c2c25d9f", X"d3d36ebd",
   X"acacef43", X"6262a6c4", X"9191a839", X"9595a431", X"e4e437d3", X"79798bf2", X"e7e732d5", X"c8c8438b", X"3737596e", X"6d6db7da",
   X"8d8d8c01", X"d5d564b1", X"4e4ed29c", X"a9a9e049", X"6c6cb4d8", X"5656faac", X"f4f407f3", X"eaea25cf", X"6565afca", X"7a7a8ef4",
   X"aeaee947", X"08081810", X"babad56f", X"787888f0", X"25256f4a", X"2e2e725c", X"1c1c2438", X"a6a6f157", X"b4b4c773", X"c6c65197",
   X"e8e823cb", X"dddd7ca1", X"74749ce8", X"1f1f213e", X"4b4bdd96", X"bdbddc61", X"8b8b860d", X"8a8a850f", X"707090e0", X"3e3e427c",
   X"b5b5c471", X"6666aacc", X"4848d890", X"03030506", X"f6f601f7", X"0e0e121c", X"6161a3c2", X"35355f6a", X"5757f9ae", X"b9b9d069",
   X"86869117", X"c1c15899", X"1d1d273a", X"9e9eb927", X"e1e138d9", X"f8f813eb", X"9898b32b", X"11113322", X"6969bbd2", X"d9d970a9",
   X"8e8e8907", X"9494a733", X"9b9bb62d", X"1e1e223c", X"87879215", X"e9e920c9", X"cece4987", X"5555ffaa", X"28287850", X"dfdf7aa5",
   X"8c8c8f03", X"a1a1f859", X"89898009", X"0d0d171a", X"bfbfda65", X"e6e631d7", X"4242c684", X"6868b8d0", X"4141c382", X"9999b029",
   X"2d2d775a", X"0f0f111e", X"b0b0cb7b", X"5454fca8", X"bbbbd66d", X"16163a2c");

 constant sbox_encoding_4 : substitution_box_type := (
   X"63636363", X"7c7c7c7c", X"77777777", X"7b7b7b7b", X"f2f2f2f2", X"6b6b6b6b", X"6f6f6f6f", X"c5c5c5c5", X"30303030", X"01010101",
   X"67676767", X"2b2b2b2b", X"fefefefe", X"d7d7d7d7", X"abababab", X"76767676", X"cacacaca", X"82828282", X"c9c9c9c9", X"7d7d7d7d",
   X"fafafafa", X"59595959", X"47474747", X"f0f0f0f0", X"adadadad", X"d4d4d4d4", X"a2a2a2a2", X"afafafaf", X"9c9c9c9c", X"a4a4a4a4",
   X"72727272", X"c0c0c0c0", X"b7b7b7b7", X"fdfdfdfd", X"93939393", X"26262626", X"36363636", X"3f3f3f3f", X"f7f7f7f7", X"cccccccc",
   X"34343434", X"a5a5a5a5", X"e5e5e5e5", X"f1f1f1f1", X"71717171", X"d8d8d8d8", X"31313131", X"15151515", X"04040404", X"c7c7c7c7",
   X"23232323", X"c3c3c3c3", X"18181818", X"96969696", X"05050505", X"9a9a9a9a", X"07070707", X"12121212", X"80808080", X"e2e2e2e2",
   X"ebebebeb", X"27272727", X"b2b2b2b2", X"75757575", X"09090909", X"83838383", X"2c2c2c2c", X"1a1a1a1a", X"1b1b1b1b", X"6e6e6e6e",
   X"5a5a5a5a", X"a0a0a0a0", X"52525252", X"3b3b3b3b", X"d6d6d6d6", X"b3b3b3b3", X"29292929", X"e3e3e3e3", X"2f2f2f2f", X"84848484",
   X"53535353", X"d1d1d1d1", X"00000000", X"edededed", X"20202020", X"fcfcfcfc", X"b1b1b1b1", X"5b5b5b5b", X"6a6a6a6a", X"cbcbcbcb",
   X"bebebebe", X"39393939", X"4a4a4a4a", X"4c4c4c4c", X"58585858", X"cfcfcfcf", X"d0d0d0d0", X"efefefef", X"aaaaaaaa", X"fbfbfbfb",
   X"43434343", X"4d4d4d4d", X"33333333", X"85858585", X"45454545", X"f9f9f9f9", X"02020202", X"7f7f7f7f", X"50505050", X"3c3c3c3c",
   X"9f9f9f9f", X"a8a8a8a8", X"51515151", X"a3a3a3a3", X"40404040", X"8f8f8f8f", X"92929292", X"9d9d9d9d", X"38383838", X"f5f5f5f5",
   X"bcbcbcbc", X"b6b6b6b6", X"dadadada", X"21212121", X"10101010", X"ffffffff", X"f3f3f3f3", X"d2d2d2d2", X"cdcdcdcd", X"0c0c0c0c",
   X"13131313", X"ecececec", X"5f5f5f5f", X"97979797", X"44444444", X"17171717", X"c4c4c4c4", X"a7a7a7a7", X"7e7e7e7e", X"3d3d3d3d",
   X"64646464", X"5d5d5d5d", X"19191919", X"73737373", X"60606060", X"81818181", X"4f4f4f4f", X"dcdcdcdc", X"22222222", X"2a2a2a2a",
   X"90909090", X"88888888", X"46464646", X"eeeeeeee", X"b8b8b8b8", X"14141414", X"dededede", X"5e5e5e5e", X"0b0b0b0b", X"dbdbdbdb",
   X"e0e0e0e0", X"32323232", X"3a3a3a3a", X"0a0a0a0a", X"49494949", X"06060606", X"24242424", X"5c5c5c5c", X"c2c2c2c2", X"d3d3d3d3",
   X"acacacac", X"62626262", X"91919191", X"95959595", X"e4e4e4e4", X"79797979", X"e7e7e7e7", X"c8c8c8c8", X"37373737", X"6d6d6d6d",
   X"8d8d8d8d", X"d5d5d5d5", X"4e4e4e4e", X"a9a9a9a9", X"6c6c6c6c", X"56565656", X"f4f4f4f4", X"eaeaeaea", X"65656565", X"7a7a7a7a",
   X"aeaeaeae", X"08080808", X"babababa", X"78787878", X"25252525", X"2e2e2e2e", X"1c1c1c1c", X"a6a6a6a6", X"b4b4b4b4", X"c6c6c6c6",
   X"e8e8e8e8", X"dddddddd", X"74747474", X"1f1f1f1f", X"4b4b4b4b", X"bdbdbdbd", X"8b8b8b8b", X"8a8a8a8a", X"70707070", X"3e3e3e3e",
   X"b5b5b5b5", X"66666666", X"48484848", X"03030303", X"f6f6f6f6", X"0e0e0e0e", X"61616161", X"35353535", X"57575757", X"b9b9b9b9",
   X"86868686", X"c1c1c1c1", X"1d1d1d1d", X"9e9e9e9e", X"e1e1e1e1", X"f8f8f8f8", X"98989898", X"11111111", X"69696969", X"d9d9d9d9",
   X"8e8e8e8e", X"94949494", X"9b9b9b9b", X"1e1e1e1e", X"87878787", X"e9e9e9e9", X"cececece", X"55555555", X"28282828", X"dfdfdfdf",
   X"8c8c8c8c", X"a1a1a1a1", X"89898989", X"0d0d0d0d", X"bfbfbfbf", X"e6e6e6e6", X"42424242", X"68686868", X"41414141", X"99999999",
   X"2d2d2d2d", X"0f0f0f0f", X"b0b0b0b0", X"54545454", X"bbbbbbbb", X"16161616");

 constant sbox_decoding_0 : substitution_box_type := (
   X"51f4a750", X"7e416553", X"1a17a4c3", X"3a275e96", X"3bab6bcb", X"1f9d45f1", X"acfa58ab", X"4be30393", X"2030fa55", X"ad766df6",
   X"88cc7691", X"f5024c25", X"4fe5d7fc", X"c52acbd7", X"26354480", X"b562a38f", X"deb15a49", X"25ba1b67", X"45ea0e98", X"5dfec0e1",
   X"c32f7502", X"814cf012", X"8d4697a3", X"6bd3f9c6", X"038f5fe7", X"15929c95", X"bf6d7aeb", X"955259da", X"d4be832d", X"587421d3",
   X"49e06929", X"8ec9c844", X"75c2896a", X"f48e7978", X"99583e6b", X"27b971dd", X"bee14fb6", X"f088ad17", X"c920ac66", X"7dce3ab4",
   X"63df4a18", X"e51a3182", X"97513360", X"62537f45", X"b16477e0", X"bb6bae84", X"fe81a01c", X"f9082b94", X"70486858", X"8f45fd19",
   X"94de6c87", X"527bf8b7", X"ab73d323", X"724b02e2", X"e31f8f57", X"6655ab2a", X"b2eb2807", X"2fb5c203", X"86c57b9a", X"d33708a5",
   X"302887f2", X"23bfa5b2", X"02036aba", X"ed16825c", X"8acf1c2b", X"a779b492", X"f307f2f0", X"4e69e2a1", X"65daf4cd", X"0605bed5",
   X"d134621f", X"c4a6fe8a", X"342e539d", X"a2f355a0", X"058ae132", X"a4f6eb75", X"0b83ec39", X"4060efaa", X"5e719f06", X"bd6e1051",
   X"3e218af9", X"96dd063d", X"dd3e05ae", X"4de6bd46", X"91548db5", X"71c45d05", X"0406d46f", X"605015ff", X"1998fb24", X"d6bde997",
   X"894043cc", X"67d99e77", X"b0e842bd", X"07898b88", X"e7195b38", X"79c8eedb", X"a17c0a47", X"7c420fe9", X"f8841ec9", X"00000000",
   X"09808683", X"322bed48", X"1e1170ac", X"6c5a724e", X"fd0efffb", X"0f853856", X"3daed51e", X"362d3927", X"0a0fd964", X"685ca621",
   X"9b5b54d1", X"24362e3a", X"0c0a67b1", X"9357e70f", X"b4ee96d2", X"1b9b919e", X"80c0c54f", X"61dc20a2", X"5a774b69", X"1c121a16",
   X"e293ba0a", X"c0a02ae5", X"3c22e043", X"121b171d", X"0e090d0b", X"f28bc7ad", X"2db6a8b9", X"141ea9c8", X"57f11985", X"af75074c",
   X"ee99ddbb", X"a37f60fd", X"f701269f", X"5c72f5bc", X"44663bc5", X"5bfb7e34", X"8b432976", X"cb23c6dc", X"b6edfc68", X"b8e4f163",
   X"d731dcca", X"42638510", X"13972240", X"84c61120", X"854a247d", X"d2bb3df8", X"aef93211", X"c729a16d", X"1d9e2f4b", X"dcb230f3",
   X"0d8652ec", X"77c1e3d0", X"2bb3166c", X"a970b999", X"119448fa", X"47e96422", X"a8fc8cc4", X"a0f03f1a", X"567d2cd8", X"223390ef",
   X"87494ec7", X"d938d1c1", X"8ccaa2fe", X"98d40b36", X"a6f581cf", X"a57ade28", X"dab78e26", X"3fadbfa4", X"2c3a9de4", X"5078920d",
   X"6a5fcc9b", X"547e4662", X"f68d13c2", X"90d8b8e8", X"2e39f75e", X"82c3aff5", X"9f5d80be", X"69d0937c", X"6fd52da9", X"cf2512b3",
   X"c8ac993b", X"10187da7", X"e89c636e", X"db3bbb7b", X"cd267809", X"6e5918f4", X"ec9ab701", X"834f9aa8", X"e6956e65", X"aaffe67e",
   X"21bccf08", X"ef15e8e6", X"bae79bd9", X"4a6f36ce", X"ea9f09d4", X"29b07cd6", X"31a4b2af", X"2a3f2331", X"c6a59430", X"35a266c0",
   X"744ebc37", X"fc82caa6", X"e090d0b0", X"33a7d815", X"f104984a", X"41ecdaf7", X"7fcd500e", X"1791f62f", X"764dd68d", X"43efb04d",
   X"ccaa4d54", X"e49604df", X"9ed1b5e3", X"4c6a881b", X"c12c1fb8", X"4665517f", X"9d5eea04", X"018c355d", X"fa877473", X"fb0b412e",
   X"b3671d5a", X"92dbd252", X"e9105633", X"6dd64713", X"9ad7618c", X"37a10c7a", X"59f8148e", X"eb133c89", X"cea927ee", X"b761c935",
   X"e11ce5ed", X"7a47b13c", X"9cd2df59", X"55f2733f", X"1814ce79", X"73c737bf", X"53f7cdea", X"5ffdaa5b", X"df3d6f14", X"7844db86",
   X"caaff381", X"b968c43e", X"3824342c", X"c2a3405f", X"161dc372", X"bce2250c", X"283c498b", X"ff0d9541", X"39a80171", X"080cb3de",
   X"d8b4e49c", X"6456c190", X"7bcb8461", X"d532b670", X"486c5c74", X"d0b85742");

 constant sbox_decoding_1 : substitution_box_type := (
   X"5051f4a7", X"537e4165", X"c31a17a4", X"963a275e", X"cb3bab6b", X"f11f9d45", X"abacfa58", X"934be303", X"552030fa", X"f6ad766d",
   X"9188cc76", X"25f5024c", X"fc4fe5d7", X"d7c52acb", X"80263544", X"8fb562a3", X"49deb15a", X"6725ba1b", X"9845ea0e", X"e15dfec0",
   X"02c32f75", X"12814cf0", X"a38d4697", X"c66bd3f9", X"e7038f5f", X"9515929c", X"ebbf6d7a", X"da955259", X"2dd4be83", X"d3587421",
   X"2949e069", X"448ec9c8", X"6a75c289", X"78f48e79", X"6b99583e", X"dd27b971", X"b6bee14f", X"17f088ad", X"66c920ac", X"b47dce3a",
   X"1863df4a", X"82e51a31", X"60975133", X"4562537f", X"e0b16477", X"84bb6bae", X"1cfe81a0", X"94f9082b", X"58704868", X"198f45fd",
   X"8794de6c", X"b7527bf8", X"23ab73d3", X"e2724b02", X"57e31f8f", X"2a6655ab", X"07b2eb28", X"032fb5c2", X"9a86c57b", X"a5d33708",
   X"f2302887", X"b223bfa5", X"ba02036a", X"5ced1682", X"2b8acf1c", X"92a779b4", X"f0f307f2", X"a14e69e2", X"cd65daf4", X"d50605be",
   X"1fd13462", X"8ac4a6fe", X"9d342e53", X"a0a2f355", X"32058ae1", X"75a4f6eb", X"390b83ec", X"aa4060ef", X"065e719f", X"51bd6e10",
   X"f93e218a", X"3d96dd06", X"aedd3e05", X"464de6bd", X"b591548d", X"0571c45d", X"6f0406d4", X"ff605015", X"241998fb", X"97d6bde9",
   X"cc894043", X"7767d99e", X"bdb0e842", X"8807898b", X"38e7195b", X"db79c8ee", X"47a17c0a", X"e97c420f", X"c9f8841e", X"00000000",
   X"83098086", X"48322bed", X"ac1e1170", X"4e6c5a72", X"fbfd0eff", X"560f8538", X"1e3daed5", X"27362d39", X"640a0fd9", X"21685ca6",
   X"d19b5b54", X"3a24362e", X"b10c0a67", X"0f9357e7", X"d2b4ee96", X"9e1b9b91", X"4f80c0c5", X"a261dc20", X"695a774b", X"161c121a",
   X"0ae293ba", X"e5c0a02a", X"433c22e0", X"1d121b17", X"0b0e090d", X"adf28bc7", X"b92db6a8", X"c8141ea9", X"8557f119", X"4caf7507",
   X"bbee99dd", X"fda37f60", X"9ff70126", X"bc5c72f5", X"c544663b", X"345bfb7e", X"768b4329", X"dccb23c6", X"68b6edfc", X"63b8e4f1",
   X"cad731dc", X"10426385", X"40139722", X"2084c611", X"7d854a24", X"f8d2bb3d", X"11aef932", X"6dc729a1", X"4b1d9e2f", X"f3dcb230",
   X"ec0d8652", X"d077c1e3", X"6c2bb316", X"99a970b9", X"fa119448", X"2247e964", X"c4a8fc8c", X"1aa0f03f", X"d8567d2c", X"ef223390",
   X"c787494e", X"c1d938d1", X"fe8ccaa2", X"3698d40b", X"cfa6f581", X"28a57ade", X"26dab78e", X"a43fadbf", X"e42c3a9d", X"0d507892",
   X"9b6a5fcc", X"62547e46", X"c2f68d13", X"e890d8b8", X"5e2e39f7", X"f582c3af", X"be9f5d80", X"7c69d093", X"a96fd52d", X"b3cf2512",
   X"3bc8ac99", X"a710187d", X"6ee89c63", X"7bdb3bbb", X"09cd2678", X"f46e5918", X"01ec9ab7", X"a8834f9a", X"65e6956e", X"7eaaffe6",
   X"0821bccf", X"e6ef15e8", X"d9bae79b", X"ce4a6f36", X"d4ea9f09", X"d629b07c", X"af31a4b2", X"312a3f23", X"30c6a594", X"c035a266",
   X"37744ebc", X"a6fc82ca", X"b0e090d0", X"1533a7d8", X"4af10498", X"f741ecda", X"0e7fcd50", X"2f1791f6", X"8d764dd6", X"4d43efb0",
   X"54ccaa4d", X"dfe49604", X"e39ed1b5", X"1b4c6a88", X"b8c12c1f", X"7f466551", X"049d5eea", X"5d018c35", X"73fa8774", X"2efb0b41",
   X"5ab3671d", X"5292dbd2", X"33e91056", X"136dd647", X"8c9ad761", X"7a37a10c", X"8e59f814", X"89eb133c", X"eecea927", X"35b761c9",
   X"ede11ce5", X"3c7a47b1", X"599cd2df", X"3f55f273", X"791814ce", X"bf73c737", X"ea53f7cd", X"5b5ffdaa", X"14df3d6f", X"867844db",
   X"81caaff3", X"3eb968c4", X"2c382434", X"5fc2a340", X"72161dc3", X"0cbce225", X"8b283c49", X"41ff0d95", X"7139a801", X"de080cb3",
   X"9cd8b4e4", X"906456c1", X"617bcb84", X"70d532b6", X"74486c5c", X"42d0b857");

 constant sbox_decoding_2 : substitution_box_type := (
  X"a75051f4", X"65537e41", X"a4c31a17", X"5e963a27",
  X"6bcb3bab", X"45f11f9d", X"58abacfa", X"03934be3",
  X"fa552030", X"6df6ad76", X"769188cc", X"4c25f502",
  X"d7fc4fe5", X"cbd7c52a", X"44802635", X"a38fb562",
  X"5a49deb1", X"1b6725ba", X"0e9845ea", X"c0e15dfe",
  X"7502c32f", X"f012814c", X"97a38d46", X"f9c66bd3",
  X"5fe7038f", X"9c951592", X"7aebbf6d", X"59da9552",
  X"832dd4be", X"21d35874", X"692949e0", X"c8448ec9",
  X"896a75c2", X"7978f48e", X"3e6b9958", X"71dd27b9",
  X"4fb6bee1", X"ad17f088", X"ac66c920", X"3ab47dce",
  X"4a1863df", X"3182e51a", X"33609751", X"7f456253",
  X"77e0b164", X"ae84bb6b", X"a01cfe81", X"2b94f908",
  X"68587048", X"fd198f45", X"6c8794de", X"f8b7527b",
  X"d323ab73", X"02e2724b", X"8f57e31f", X"ab2a6655",
  X"2807b2eb", X"c2032fb5", X"7b9a86c5", X"08a5d337",
  X"87f23028", X"a5b223bf", X"6aba0203", X"825ced16",
  X"1c2b8acf", X"b492a779", X"f2f0f307", X"e2a14e69",
  X"f4cd65da", X"bed50605", X"621fd134", X"fe8ac4a6",
  X"539d342e", X"55a0a2f3", X"e132058a", X"eb75a4f6",
  X"ec390b83", X"efaa4060", X"9f065e71", X"1051bd6e",
  X"8af93e21", X"063d96dd", X"05aedd3e", X"bd464de6",
  X"8db59154", X"5d0571c4", X"d46f0406", X"15ff6050",
  X"fb241998", X"e997d6bd", X"43cc8940", X"9e7767d9",
  X"42bdb0e8", X"8b880789", X"5b38e719", X"eedb79c8",
  X"0a47a17c", X"0fe97c42", X"1ec9f884", X"00000000",
  X"86830980", X"ed48322b", X"70ac1e11", X"724e6c5a",
  X"fffbfd0e", X"38560f85", X"d51e3dae", X"3927362d",
  X"d9640a0f", X"a621685c", X"54d19b5b", X"2e3a2436",
  X"67b10c0a", X"e70f9357", X"96d2b4ee", X"919e1b9b",
  X"c54f80c0", X"20a261dc", X"4b695a77", X"1a161c12",
  X"ba0ae293", X"2ae5c0a0", X"e0433c22", X"171d121b",
  X"0d0b0e09", X"c7adf28b", X"a8b92db6", X"a9c8141e",
  X"198557f1", X"074caf75", X"ddbbee99", X"60fda37f",
  X"269ff701", X"f5bc5c72", X"3bc54466", X"7e345bfb",
  X"29768b43", X"c6dccb23", X"fc68b6ed", X"f163b8e4",
  X"dccad731", X"85104263", X"22401397", X"112084c6",
  X"247d854a", X"3df8d2bb", X"3211aef9", X"a16dc729",
  X"2f4b1d9e", X"30f3dcb2", X"52ec0d86", X"e3d077c1",
  X"166c2bb3", X"b999a970", X"48fa1194", X"642247e9",
  X"8cc4a8fc", X"3f1aa0f0", X"2cd8567d", X"90ef2233",
  X"4ec78749", X"d1c1d938", X"a2fe8cca", X"0b3698d4",
  X"81cfa6f5", X"de28a57a", X"8e26dab7", X"bfa43fad",
  X"9de42c3a", X"920d5078", X"cc9b6a5f", X"4662547e",
  X"13c2f68d", X"b8e890d8", X"f75e2e39", X"aff582c3",
  X"80be9f5d", X"937c69d0", X"2da96fd5", X"12b3cf25",
  X"993bc8ac", X"7da71018", X"636ee89c", X"bb7bdb3b",
  X"7809cd26", X"18f46e59", X"b701ec9a", X"9aa8834f",
  X"6e65e695", X"e67eaaff", X"cf0821bc", X"e8e6ef15",
  X"9bd9bae7", X"36ce4a6f", X"09d4ea9f", X"7cd629b0",
  X"b2af31a4", X"23312a3f", X"9430c6a5", X"66c035a2",
  X"bc37744e", X"caa6fc82", X"d0b0e090", X"d81533a7",
  X"984af104", X"daf741ec", X"500e7fcd", X"f62f1791",
  X"d68d764d", X"b04d43ef", X"4d54ccaa", X"04dfe496",
  X"b5e39ed1", X"881b4c6a", X"1fb8c12c", X"517f4665",
  X"ea049d5e", X"355d018c", X"7473fa87", X"412efb0b",
  X"1d5ab367", X"d25292db", X"5633e910", X"47136dd6",
  X"618c9ad7", X"0c7a37a1", X"148e59f8", X"3c89eb13",
  X"27eecea9", X"c935b761", X"e5ede11c", X"b13c7a47",
  X"df599cd2", X"733f55f2", X"ce791814", X"37bf73c7",
  X"cdea53f7", X"aa5b5ffd", X"6f14df3d", X"db867844",
  X"f381caaf", X"c43eb968", X"342c3824", X"405fc2a3",
  X"c372161d", X"250cbce2", X"498b283c", X"9541ff0d",
  X"017139a8", X"b3de080c", X"e49cd8b4", X"c1906456",
  X"84617bcb", X"b670d532", X"5c74486c", X"5742d0b8");

constant sbox_decoding_3 : substitution_box_type := (
  X"f4a75051", X"4165537e", X"17a4c31a", X"275e963a",
  X"ab6bcb3b", X"9d45f11f", X"fa58abac", X"e303934b",
  X"30fa5520", X"766df6ad", X"cc769188", X"024c25f5",
  X"e5d7fc4f", X"2acbd7c5", X"35448026", X"62a38fb5",
  X"b15a49de", X"ba1b6725", X"ea0e9845", X"fec0e15d",
  X"2f7502c3", X"4cf01281", X"4697a38d", X"d3f9c66b",
  X"8f5fe703", X"929c9515", X"6d7aebbf", X"5259da95",
  X"be832dd4", X"7421d358", X"e0692949", X"c9c8448e",
  X"c2896a75", X"8e7978f4", X"583e6b99", X"b971dd27",
  X"e14fb6be", X"88ad17f0", X"20ac66c9", X"ce3ab47d",
  X"df4a1863", X"1a3182e5", X"51336097", X"537f4562",
  X"6477e0b1", X"6bae84bb", X"81a01cfe", X"082b94f9",
  X"48685870", X"45fd198f", X"de6c8794", X"7bf8b752",
  X"73d323ab", X"4b02e272", X"1f8f57e3", X"55ab2a66",
  X"eb2807b2", X"b5c2032f", X"c57b9a86", X"3708a5d3",
  X"2887f230", X"bfa5b223", X"036aba02", X"16825ced",
  X"cf1c2b8a", X"79b492a7", X"07f2f0f3", X"69e2a14e",
  X"daf4cd65", X"05bed506", X"34621fd1", X"a6fe8ac4",
  X"2e539d34", X"f355a0a2", X"8ae13205", X"f6eb75a4",
  X"83ec390b", X"60efaa40", X"719f065e", X"6e1051bd",
  X"218af93e", X"dd063d96", X"3e05aedd", X"e6bd464d",
  X"548db591", X"c45d0571", X"06d46f04", X"5015ff60",
  X"98fb2419", X"bde997d6", X"4043cc89", X"d99e7767",
  X"e842bdb0", X"898b8807", X"195b38e7", X"c8eedb79",
  X"7c0a47a1", X"420fe97c", X"841ec9f8", X"00000000",
  X"80868309", X"2bed4832", X"1170ac1e", X"5a724e6c",
  X"0efffbfd", X"8538560f", X"aed51e3d", X"2d392736",
  X"0fd9640a", X"5ca62168", X"5b54d19b", X"362e3a24",
  X"0a67b10c", X"57e70f93", X"ee96d2b4", X"9b919e1b",
  X"c0c54f80", X"dc20a261", X"774b695a", X"121a161c",
  X"93ba0ae2", X"a02ae5c0", X"22e0433c", X"1b171d12",
  X"090d0b0e", X"8bc7adf2", X"b6a8b92d", X"1ea9c814",
  X"f1198557", X"75074caf", X"99ddbbee", X"7f60fda3",
  X"01269ff7", X"72f5bc5c", X"663bc544", X"fb7e345b",
  X"4329768b", X"23c6dccb", X"edfc68b6", X"e4f163b8",
  X"31dccad7", X"63851042", X"97224013", X"c6112084",
  X"4a247d85", X"bb3df8d2", X"f93211ae", X"29a16dc7",
  X"9e2f4b1d", X"b230f3dc", X"8652ec0d", X"c1e3d077",
  X"b3166c2b", X"70b999a9", X"9448fa11", X"e9642247",
  X"fc8cc4a8", X"f03f1aa0", X"7d2cd856", X"3390ef22",
  X"494ec787", X"38d1c1d9", X"caa2fe8c", X"d40b3698",
  X"f581cfa6", X"7ade28a5", X"b78e26da", X"adbfa43f",
  X"3a9de42c", X"78920d50", X"5fcc9b6a", X"7e466254",
  X"8d13c2f6", X"d8b8e890", X"39f75e2e", X"c3aff582",
  X"5d80be9f", X"d0937c69", X"d52da96f", X"2512b3cf",
  X"ac993bc8", X"187da710", X"9c636ee8", X"3bbb7bdb",
  X"267809cd", X"5918f46e", X"9ab701ec", X"4f9aa883",
  X"956e65e6", X"ffe67eaa", X"bccf0821", X"15e8e6ef",
  X"e79bd9ba", X"6f36ce4a", X"9f09d4ea", X"b07cd629",
  X"a4b2af31", X"3f23312a", X"a59430c6", X"a266c035",
  X"4ebc3774", X"82caa6fc", X"90d0b0e0", X"a7d81533",
  X"04984af1", X"ecdaf741", X"cd500e7f", X"91f62f17",
  X"4dd68d76", X"efb04d43", X"aa4d54cc", X"9604dfe4",
  X"d1b5e39e", X"6a881b4c", X"2c1fb8c1", X"65517f46",
  X"5eea049d", X"8c355d01", X"877473fa", X"0b412efb",
  X"671d5ab3", X"dbd25292", X"105633e9", X"d647136d",
  X"d7618c9a", X"a10c7a37", X"f8148e59", X"133c89eb",
  X"a927eece", X"61c935b7", X"1ce5ede1", X"47b13c7a",
  X"d2df599c", X"f2733f55", X"14ce7918", X"c737bf73",
  X"f7cdea53", X"fdaa5b5f", X"3d6f14df", X"44db8678",
  X"aff381ca", X"68c43eb9", X"24342c38", X"a3405fc2",
  X"1dc37216", X"e2250cbc", X"3c498b28", X"0d9541ff",
  X"a8017139", X"0cb3de08", X"b4e49cd8", X"56c19064",
  X"cb84617b", X"32b670d5", X"6c5c7448", X"b85742d0");
  
constant sbox_decoding_4 : substitution_box_type := (
  X"52525252", X"09090909", X"6a6a6a6a", X"d5d5d5d5",
  X"30303030", X"36363636", X"a5a5a5a5", X"38383838",
  X"bfbfbfbf", X"40404040", X"a3a3a3a3", X"9e9e9e9e",
  X"81818181", X"f3f3f3f3", X"d7d7d7d7", X"fbfbfbfb",
  X"7c7c7c7c", X"e3e3e3e3", X"39393939", X"82828282",
  X"9b9b9b9b", X"2f2f2f2f", X"ffffffff", X"87878787",
  X"34343434", X"8e8e8e8e", X"43434343", X"44444444",
  X"c4c4c4c4", X"dededede", X"e9e9e9e9", X"cbcbcbcb",
  X"54545454", X"7b7b7b7b", X"94949494", X"32323232",
  X"a6a6a6a6", X"c2c2c2c2", X"23232323", X"3d3d3d3d",
  X"eeeeeeee", X"4c4c4c4c", X"95959595", X"0b0b0b0b",
  X"42424242", X"fafafafa", X"c3c3c3c3", X"4e4e4e4e",
  X"08080808", X"2e2e2e2e", X"a1a1a1a1", X"66666666",
  X"28282828", X"d9d9d9d9", X"24242424", X"b2b2b2b2",
  X"76767676", X"5b5b5b5b", X"a2a2a2a2", X"49494949",
  X"6d6d6d6d", X"8b8b8b8b", X"d1d1d1d1", X"25252525",
  X"72727272", X"f8f8f8f8", X"f6f6f6f6", X"64646464",
  X"86868686", X"68686868", X"98989898", X"16161616",
  X"d4d4d4d4", X"a4a4a4a4", X"5c5c5c5c", X"cccccccc",
  X"5d5d5d5d", X"65656565", X"b6b6b6b6", X"92929292",
  X"6c6c6c6c", X"70707070", X"48484848", X"50505050",
  X"fdfdfdfd", X"edededed", X"b9b9b9b9", X"dadadada",
  X"5e5e5e5e", X"15151515", X"46464646", X"57575757",
  X"a7a7a7a7", X"8d8d8d8d", X"9d9d9d9d", X"84848484",
  X"90909090", X"d8d8d8d8", X"abababab", X"00000000",
  X"8c8c8c8c", X"bcbcbcbc", X"d3d3d3d3", X"0a0a0a0a",
  X"f7f7f7f7", X"e4e4e4e4", X"58585858", X"05050505",
  X"b8b8b8b8", X"b3b3b3b3", X"45454545", X"06060606",
  X"d0d0d0d0", X"2c2c2c2c", X"1e1e1e1e", X"8f8f8f8f",
  X"cacacaca", X"3f3f3f3f", X"0f0f0f0f", X"02020202",
  X"c1c1c1c1", X"afafafaf", X"bdbdbdbd", X"03030303",
  X"01010101", X"13131313", X"8a8a8a8a", X"6b6b6b6b",
  X"3a3a3a3a", X"91919191", X"11111111", X"41414141",
  X"4f4f4f4f", X"67676767", X"dcdcdcdc", X"eaeaeaea",
  X"97979797", X"f2f2f2f2", X"cfcfcfcf", X"cececece",
  X"f0f0f0f0", X"b4b4b4b4", X"e6e6e6e6", X"73737373",
  X"96969696", X"acacacac", X"74747474", X"22222222",
  X"e7e7e7e7", X"adadadad", X"35353535", X"85858585",
  X"e2e2e2e2", X"f9f9f9f9", X"37373737", X"e8e8e8e8",
  X"1c1c1c1c", X"75757575", X"dfdfdfdf", X"6e6e6e6e",
  X"47474747", X"f1f1f1f1", X"1a1a1a1a", X"71717171",
  X"1d1d1d1d", X"29292929", X"c5c5c5c5", X"89898989",
  X"6f6f6f6f", X"b7b7b7b7", X"62626262", X"0e0e0e0e",
  X"aaaaaaaa", X"18181818", X"bebebebe", X"1b1b1b1b",
  X"fcfcfcfc", X"56565656", X"3e3e3e3e", X"4b4b4b4b",
  X"c6c6c6c6", X"d2d2d2d2", X"79797979", X"20202020",
  X"9a9a9a9a", X"dbdbdbdb", X"c0c0c0c0", X"fefefefe",
  X"78787878", X"cdcdcdcd", X"5a5a5a5a", X"f4f4f4f4",
  X"1f1f1f1f", X"dddddddd", X"a8a8a8a8", X"33333333",
  X"88888888", X"07070707", X"c7c7c7c7", X"31313131",
  X"b1b1b1b1", X"12121212", X"10101010", X"59595959",
  X"27272727", X"80808080", X"ecececec", X"5f5f5f5f",
  X"60606060", X"51515151", X"7f7f7f7f", X"a9a9a9a9",
  X"19191919", X"b5b5b5b5", X"4a4a4a4a", X"0d0d0d0d",
  X"2d2d2d2d", X"e5e5e5e5", X"7a7a7a7a", X"9f9f9f9f",
  X"93939393", X"c9c9c9c9", X"9c9c9c9c", X"efefefef",
  X"a0a0a0a0", X"e0e0e0e0", X"3b3b3b3b", X"4d4d4d4d",
  X"aeaeaeae", X"2a2a2a2a", X"f5f5f5f5", X"b0b0b0b0",
  X"c8c8c8c8", X"ebebebeb", X"bbbbbbbb", X"3c3c3c3c",
  X"83838383", X"53535353", X"99999999", X"61616161",
  X"17171717", X"2b2b2b2b", X"04040404", X"7e7e7e7e",
  X"babababa", X"77777777", X"d6d6d6d6", X"26262626",
  X"e1e1e1e1", X"69696969", X"14141414", X"63636363",
  X"55555555", X"21212121", X"0c0c0c0c", X"7d7d7d7d");
  
type rcon_type is array (0 to 9) of std_logic_vector(0 to 31);
constant rcon : rcon_type := (X"01000000", X"02000000", X"04000000", X"08000000", X"10000000",
                              X"20000000", X"40000000", X"80000000", X"1B000000", X"36000000");

component  round_decoder is
  port (
    in_clk                      : in  std_logic;
    in_reset                    : in  std_logic;
    in_cipher_key               : in  std_logic_vector(0 to 127);
    in_intermediate_data        : in  std_logic_vector(0 to 127);
    in_intermediate_data_valid  : in  std_logic;
    out_intermediate_data       : out std_logic_vector(0 to 127);
    out_intermediate_data_valid : out std_logic);
end component round_decoder;

component round_encoder is
  port (
    in_clk                      : in  std_logic;
    in_reset                    : in  std_logic;
    in_cipher_key               : in  std_logic_vector(0 to 127);
    in_intermediate_data        : in  std_logic_vector(0 to 127);
    in_intermediate_data_valid  : in  std_logic;
    out_intermediate_data       : out std_logic_vector(0 to 127);
    out_intermediate_data_valid : out std_logic);
end component round_encoder;

component aes_encoding_128 is
  port (
    in_clk                      : in  std_logic;
    in_reset                    : in  std_logic;
    in_new_cipher_key           : in  std_logic;
    in_expanded_key_data        : in  std_logic_vector(0 to 127);
    in_expanded_key_valid       : in  std_logic;
    in_expanded_key_ready       : in  std_logic;
    out_expanded_key_start      : out std_logic;
    in_plain_data               : in  std_logic_vector(0 to 127);
    in_plain_data_valid         : in  std_logic;
    out_cipher_data             : out std_logic_vector(0 to 127);
    out_cipher_data_valid       : out std_logic;
    out_ready                   : out std_logic);
end component aes_encoding_128;

component aes_decoding_128 is
  port (
    in_clk                 : in std_logic;
    in_reset               : in std_logic;
    in_new_cipher_key      : in std_logic;
    in_expanded_key_data   : in std_logic_vector (0 to 127);
    in_expanded_key_valid  : in std_logic;
    in_expanded_key_ready  : in std_logic;
    out_expanded_key_start : out std_logic;
    out_plain_data         : out std_logic_vector(0 to 127);
    out_plain_data_valid   : out std_logic;
    in_cipher_data         : in std_logic_vector(0 to 127);
    in_cipher_data_valid   : in std_logic;
    out_ready              : out std_logic);
end component aes_decoding_128;

component cipher_key_expansion_128
  port (
    in_clk             : in std_logic;
    in_reset           : in std_logic;
    in_cipher_key      : in std_logic_vector(0 to 127);
    in_request         : in std_logic;
    out_cipher_key     : out std_logic_vector(0 to 127);
    out_valid          : out std_logic;
    out_ready          : out std_logic);
end component cipher_key_expansion_128;

component aes_cipher_block_128 is
  port (
    in_clk                              : in  std_logic;
    in_reset                            : in  std_logic;  
    in_cipher_key                       : in  std_logic_vector(0 to 127);
    in_cipher_key_valid_to_encoder    : in  std_logic;
    in_cipher_key_valid_to_decoder    : in  std_logic;
    out_plain_data                      : out std_logic_vector(0 to 127);
    out_plain_data_valid                : out std_logic;
    in_cipher_data                      : in  std_logic_vector(0 to 127);
    in_cipher_data_valid                : in  std_logic;
    in_plain_data                       : in  std_logic_vector(0 to 127);
    in_plain_data_valid                 : in  std_logic;
    out_cipher_data                     : out std_logic_vector(0 to 127);
    out_cipher_data_valid               : out std_logic;
    out_decoder_ready                   : out std_logic;
    out_encoder_ready                   : out std_logic);
end component aes_cipher_block_128;

end package aes_pkg;


