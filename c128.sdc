derive_pll_clocks
derive_clock_uncertainty

# The VDC and reconfigurable video PLLs have no stable phase relationship to
# each other or to the system/framework clocks. Keep the main core PLL outputs
# related, but cut transfers to and from these independent video domains.
set core_video_clocks [get_clocks {emu|video_switch|pll_video|pll_video_inst|altera_pll_i|*|divclk}]
set vdc_video_clocks  [get_clocks {emu|pll_vdc|pll_vdc_inst|altera_pll_i|*|divclk}]

set video_clocks_available [expr {
   [get_collection_size $core_video_clocks] != 0 &&
   [get_collection_size $vdc_video_clocks] != 0
}]

if {$video_clocks_available} {
   set_clock_groups -asynchronous \
      -group $core_video_clocks \
      -group $vdc_video_clocks \
      -group [get_clocks {emu|pll|pll_inst|altera_pll_i|*|divclk}] \
      -group [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|*[0].*|divclk}] \
      -group [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|*[0].*|divclk}] \
      -group [get_clocks {spi_sck}] \
      -group [get_clocks {hdmi_sck}] \
      -group [get_clocks {*|h2f_user0_clk}] \
      -group [get_clocks {FPGA_CLK1_50}] \
      -group [get_clocks {FPGA_CLK2_50}] \
      -group [get_clocks {FPGA_CLK3_50}]
} elseif {[info exists ::quartus(nameofexecutable)] &&
          $::quartus(nameofexecutable) eq "quartus_sta"} {
   error "The reconfigurable core video or VDC video clock was not found"
}

set_false_path -to   {emu|fpga64|vdc|*}

set_false_path -from {emu|fpga64|reset}
set_false_path -from {emu|fpga64|reset_t80}

set_false_path -from {emu|fpga64|Keyboard|*}
set_false_path -to   {emu|fpga64|Keyboard|*}
