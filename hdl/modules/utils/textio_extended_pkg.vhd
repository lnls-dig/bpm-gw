library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Package extraceted from stackoverflow response
-- http://stackoverflow.com/questions/24329155/is-there-a-way-to-print-the-values-of-a-signal-to-a-file-from-a-modelsim-simulat

library work;

package textio_extended_pkg is

  function imin(arg1 : integer; arg2 : integer) return integer;
  function imax(arg1 : integer; arg2 : integer) return integer;
  function ite(cond : boolean; value1 : string; value2 : string) return string;
  function ite(cond : boolean; value1 : integer; value2 : integer) return integer;

  function to_upper(c: character) return character;
  function to_lower(c: character) return character;
  function to_upper(s: string) return string;
  function to_lower(s: string) return string;

  function to_char(value : std_logic) return character;
  function to_char(value : natural) return character;

  function resize(vec : std_logic_vector; length : natural; fill : std_logic := '0') return std_logic_vector;

  function to_string(value : boolean) return string;
  function to_string(slv : std_logic_vector; format : character; length : natural := 0; fill : character := '0') return string;

end textio_extended_pkg;

package body textio_extended_pkg is

  -- calculate the minimum of two inputs
  function imin(arg1 : integer; arg2 : integer) return integer is
  begin
    if arg1 < arg2 then
      return arg1;
    end if;

    return arg2;
  end function;

  function imax(arg1 : integer; arg2 : integer) return integer is
  begin
    if arg1 > arg2 then
      return arg1;
    end if;

    return arg2;
  end function;

  -- if-then-else for strings
  function ite(cond : boolean; value1 : string; value2 : string) return string is
  begin
    if cond then
      return value1;
    else
      return value2;
    end if;
  end function;

  -- if-then-else for strings
  function ite(cond : boolean; value1 : integer; value2 : integer) return integer is
  begin
    if cond then
      return value1;
    else
      return value2;
    end if;
  end function;

  function to_char(value : std_logic) return character is
  begin
    case value is
      when 'U' =>     return 'U';
      when 'X' =>     return 'X';
      when '0' =>     return '0';
      when '1' =>     return '1';
      when 'Z' =>     return 'Z';
      when 'W' =>     return 'W';
      when 'L' =>     return 'L';
      when 'H' =>     return 'H';
      when '-' =>     return '-';
      when others =>  return 'X';
    end case;
  end function;

  function to_upper(c: character) return character is
    variable u: character;
  begin
    case c is
      when 'a' => u := 'A';
      when 'b' => u := 'B';
      when 'c' => u := 'C';
      when 'd' => u := 'D';
      when 'e' => u := 'E';
      when 'f' => u := 'F';
      when 'g' => u := 'G';
      when 'h' => u := 'H';
      when 'i' => u := 'I';
      when 'j' => u := 'J';
      when 'k' => u := 'K';
      when 'l' => u := 'L';
      when 'm' => u := 'M';
      when 'n' => u := 'N';
      when 'o' => u := 'O';
      when 'p' => u := 'P';
      when 'q' => u := 'Q';
      when 'r' => u := 'R';
      when 's' => u := 'S';
      when 't' => u := 'T';
      when 'u' => u := 'U';
      when 'v' => u := 'V';
      when 'w' => u := 'W';
      when 'x' => u := 'X';
      when 'y' => u := 'Y';
      when 'z' => u := 'Z';
      when others => u := c;
    end case;

     return u;
  end to_upper;

  function to_lower(c: character) return character is
    variable l: character;
  begin
    case c is
      when 'A' => l := 'a';
      when 'B' => l := 'b';
      when 'C' => l := 'c';
      when 'D' => l := 'd';
      when 'E' => l := 'e';
      when 'F' => l := 'f';
      when 'G' => l := 'g';
      when 'H' => l := 'h';
      when 'I' => l := 'i';
      when 'J' => l := 'j';
      when 'K' => l := 'k';
      when 'L' => l := 'l';
      when 'M' => l := 'm';
      when 'N' => l := 'n';
      when 'O' => l := 'o';
      when 'P' => l := 'p';
      when 'Q' => l := 'q';
      when 'R' => l := 'r';
      when 'S' => l := 's';
      when 'T' => l := 't';
      when 'U' => l := 'u';
      when 'V' => l := 'v';
      when 'W' => l := 'w';
      when 'X' => l := 'x';
      when 'Y' => l := 'y';
      when 'Z' => l := 'z';
      when others => l := c;
    end case;

    return l;
  end to_lower;

  function to_upper(s: string) return string is
    variable uppercase: string (s'range);
  begin
    for i in s'range loop
      uppercase(i):= to_upper(s(i));
    end loop;

    return uppercase;
  end to_upper;

  function to_lower(s: string) return string is
    variable lowercase: string (s'range);
  begin
    for i in s'range loop
     lowercase(i):= to_lower(s(i));
    end loop;

    return lowercase;
  end to_lower;

  function to_char(value : natural) return character is
  begin
    if (value < 10) then
      return character'val(character'pos('0') + value);
    elsif (value < 16) then
      return character'val(character'pos('A') + value - 10);
    else
      return 'X';
    end if;
  end function;

  function to_string(value : boolean) return string is
  begin
    return to_upper(boolean'image(value));  -- ite(value, "true", "false");
  end function;

  -- a resize function for std_logic_vector
  function resize(vec : std_logic_vector; length : natural; fill : std_logic := '0') return std_logic_vector is
    constant  high2b : natural := vec'low+length-1;
    constant  highcp : natural := imin(vec'high, high2b);
    variable  res_up : std_logic_vector(vec'low to high2b);
    variable  res_dn : std_logic_vector(high2b downto vec'low);
  begin
    if vec'ascending then
      res_up := (others => fill);
      res_up(vec'low to highcp) := vec(vec'low to highcp);
      return  res_up;
    else
      res_dn := (others => fill);
      res_dn(highcp downto vec'low) := vec(highcp downto vec'low);
      return  res_dn;
    end if;
  end function;

  function to_string(slv : std_logic_vector; format : character; length : natural := 0; fill : character := '0') return string is
    constant int                    : integer               := ite((slv'length <= 31), to_integer(unsigned(resize(slv, 31))), 0);
    constant str        : string    := integer'image(int);
    constant bin_len    : positive  := slv'length;
    constant dec_len    : positive  := str'length;--log10ceilnz(int);
    constant hex_len    : positive  := ite(((bin_len mod 4) = 0), (bin_len / 4), (bin_len / 4) + 1);
    constant len        : natural   := ite((format = 'b'), bin_len,
                                       ite((format = 'd'), dec_len,
                                       ite((format = 'h'), hex_len, 0)));

    variable j          : natural   := 0;
    variable result     : string(1 to ite((length = 0), len, imax(len, length)))    := (others => fill);

  begin
    if (format = 'b') then
      for i in result'reverse_range loop
        result(i) := to_char(slv(j));
        j         := j + 1;
      end loop;
    elsif (format = 'd') then
      result(result'length - str'length + 1 to result'high) := str;
    elsif (format = 'h') then
      for i in result'reverse_range loop
        result(i) := to_char(to_integer(unsigned(slv((j * 4) + 3 downto (j * 4)))));
        j         := j + 1;
      end loop;
    else
      report "unknown format" severity failure;
    end if;

    return result;
  end function;

end textio_extended_pkg;
