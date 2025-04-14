#!/bin/bash
mkdir -p sim
iverilog -o sim/top_tb.vvp src/*.v tb/tb_top.v
vvp sim/top_tb.vvp
