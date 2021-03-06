
-- Copyright (C) 2001 Bill Billowitch.

-- Some of the work to develop this test suite was done with Air Force
-- support.  The Air Force and Bill Billowitch assume no
-- responsibilities for this software.

-- This file is part of VESTs (Vhdl tESTs).

-- VESTs is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2 of the License, or (at
-- your option) any later version. 

-- VESTs is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details. 

-- You should have received a copy of the GNU General Public License
-- along with VESTs; if not, write to the Free Software Foundation,
-- Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

-- ---------------------------------------------------------------------
--
-- $Id: tc326.vhd,v 1.2 2001-10-26 16:29:53 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

ENTITY c03s02b01x00p04n01i00326ent IS
END c03s02b01x00p04n01i00326ent;

ARCHITECTURE c03s02b01x00p04n01i00326arch OF c03s02b01x00p04n01i00326ent IS
  type rec_type is
    record
      x : integer;
      y : real;
      z : boolean;
      b : bit;
    end record;

  type array_type is array (1 to 10) of rec_type;  -- Success_here
BEGIN
  TESTING: PROCESS
    variable k : array_type;
  BEGIN
    k(1).x := 5;
    k(1).y := 1.0;
    k(1).z := true;
    k(1).b := '1';
    assert NOT(k(1).x=5 and k(1).y=1.0 and k(1).z=true and k(1).b='1') 
      report "***PASSED TEST: c03s02b01x00p04n01i00326"
      severity NOTE;
    assert (k(1).x=5 and k(1).y=1.0 and k(1).z=true and k(1).b='1') 
      report "***FAILED TEST: c03s02b01x00p04n01i00326 - The index constraint is not valid." 
      severity ERROR;
    wait;
  END PROCESS TESTING;

END c03s02b01x00p04n01i00326arch;
