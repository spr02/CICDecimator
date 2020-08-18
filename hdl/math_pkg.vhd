----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.01.2017 17:44:50
-- Design Name: 
-- Module Name: helper_util - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package math_pkg is
    function ceil_log2 (x: in integer) return integer;
    function ceil_div2 (x: in integer) return integer;
end package math_pkg;

package body math_pkg is


    function ceil_log2 (x: in integer) return integer is
        variable tmp    : integer := x;
        variable ret    : integer := 1;
    begin
        while tmp > 1 loop
            ret := ret + 1;
            tmp := tmp / 2;
        end loop;
        return ret;
    end function ceil_log2;

    function ceil_div2 (x: in integer) return integer is
        variable ret : integer;
    begin
        if x rem 2 = 0 then -- x even?
            ret := x/2;
        else
            ret := 1 + x/2;
        end if;
        return ret;
    end function ceil_div2;
    
end package body math_pkg;
