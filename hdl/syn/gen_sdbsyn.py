#!/usr/bin/python

##-----------------------------------------------------------------------------
## Title      : SDB Synthesis info autogen
## Project    : White Rabbit Switch
##-----------------------------------------------------------------------------
## File       : gen_sdbsyn.py
## Author     : Grzegorz Daniluk
## Company    : CERN BE-CO-HT
## Created    : 2014-09-17
## Last update: 2014-09-17
## Platform   : FPGA-generic
## Standard   : VHDL
##-----------------------------------------------------------------------------
## Description:
## Script for auto-generation of VHDL package with t_sdb_synthesis and
## t_sdb_repo_url info. Should be called every time before the synthesis is done
##-----------------------------------------------------------------------------
##
## Copyright (c) 2014 CERN / BE-CO-HT
##
## This source file is free software; you can redistribute it
## and/or modify it under the terms of the GNU Lesser General
## Public License as published by the Free Software Foundation;
## either version 2.1 of the License, or (at your option) any
## later version.
##
## This source is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE.  See the GNU Lesser General Public License for more
## details.
##
## You should have received a copy of the GNU Lesser General
## Public License along with this source; if not, download it
## from http://www.gnu.org/licenses/lgpl-2.1.html
##
##-----------------------------------------------------------------------------

import sys
import argparse
import subprocess
import datetime

#MODULE_NAME  = "WRS 8p"
#TOOL_NAME    = "ISE"
#TOOL_VERSION = "14.5"

PKG_FILE    = "synthesis_descriptor_pkg.vhd"
PKG_HEADER = """-- package generated automatically by gen_sdbsyn.py script --
library ieee;
use ieee.std_logic_1164.all;
use work.wishbone_pkg.all;
package synthesis_descriptor_pkg is\n"""
PKG_TAIL    = "\nend package;";

REPO_URL = "constant c_sdb_repo_url : t_sdb_repo_url := (\n"
MAIN_SYN = "top"

# from t_sdb_synthesis record
SDB_URL    = "repo_url"
URL_LEN    = 63
NAME_LEN   = 16
COMMIT_LEN = 32
TOOL_LEN   = 8
USER_LEN   = 15
VID_LEN    = 64
DID_LEN    = 32
VER_LEN    = 32
MODNAME_LEN   = 19

# git commands
GIT_DIRTY = "git describe --always --dirty=+"

# write t_sdb_synthesis record to opened file
def write_sdb_info(f, r_name, m_name, commit, dirty, tool, toolv, date, user):
  # mark dirty if necessary
  if len(m_name)<NAME_LEN and dirty:
    m_name = m_name + '+'
  elif len(m_name)>=NAME_LEN and dirty:
    m_name = m_name[:NAME_LEN-1] + '+'
  f.write("constant c_sdb_" + r_name.replace("-", "_") + "_syn_info : t_sdb_synthesis := (\n")
  f.write("syn_module_name => \"" + m_name[:NAME_LEN].ljust(NAME_LEN) + "\",\n")
  f.write("syn_commit_id => \"" + commit.ljust(COMMIT_LEN) + "\",\n")
  f.write("syn_tool_name => \"" + tool[:TOOL_LEN].ljust(TOOL_LEN) + "\",\n")
  f.write("syn_tool_version => x\""+ hex(toolv)[2:].zfill(8) + "\",\n")
  f.write("syn_date => x\"" + hex(date)[2:].zfill(8) + "\",\n")
  f.write("syn_username => \"" + user[:USER_LEN].ljust(USER_LEN) + "\");\n")

def git_username():
  # gets username from git config
  temp = subprocess.Popen("git config user.name", stdout=subprocess.PIPE, shell=True)
  user = temp.stdout.read().split()
  if len(user) == 1:
    #is a single word, so we just use it
    return user[0]
  #otherwise use initials with last name
  uname = ""
  for n in user[:-1]:
    uname = uname + n[0]
  uname = uname + user[-1]
  return uname

def main():
  ### runtime arguments
  parser = argparse.ArgumentParser(description='Script for generating sdb metadata of HDL projects')
  parser.add_argument('--user', default=git_username(), help='User who makes the synthesis')
  parser.add_argument('--project', default="", required=True, help='Friendly project name')
  parser.add_argument('--tool', default="ISE", help='Name of the synthesis tool')
  parser.add_argument('--ver', default="14.5", help='Synthesis tool version')
  parser.add_argument('-o', default=".", help='location of output file')
  args = parser.parse_args()
  if args.o[-1]!='/':
    args.o = args.o + '/'
  #######

  temp = subprocess.Popen("git rev-parse --show-toplevel", stdout=subprocess.PIPE, shell=True)
  toplevel = temp.stdout.read()[0:-1] #remove trailing \n
  f = open(args.o + PKG_FILE, 'w')
  f.write(PKG_HEADER)
  ### Make the first constant which is repo url
  f.write(REPO_URL)
  temp = subprocess.Popen("git config remote.origin.url", stdout=subprocess.PIPE, shell=True)
  url = temp.stdout.read()[0:-1]
  f.write(SDB_URL + " => \"" + url[:URL_LEN].ljust(URL_LEN) + "\");\n")   #truncate or expand string

  ### Now generate synthesis info for main repository
  # get commit id
  temp = subprocess.Popen("git log --always --pretty=format:'%H' -n 1", stdout=subprocess.PIPE, shell=True)
  commit_id = temp.stdout.read()[:32]
  dirty = False
  temp = subprocess.Popen(GIT_DIRTY, stdout=subprocess.PIPE, shell=True)
  if temp.stdout.read()[-2] == '+':
    dirty = True #commit_id = commit_id + '+'
  # get date
  day = datetime.datetime.today().day
  mon = datetime.datetime.today().month
  year = datetime.datetime.today().year
  date = int(str(year*10000 + mon*100 + day), 16)  # strange, I know, but I want to have something like x"20140917"
  # convert version
  ver = int(args.ver.translate(None, '.,'), 16)
  # fill this all to the structure
  write_sdb_info(f, MAIN_SYN, args.project, commit_id, dirty, args.tool, ver, date, args.user)

  ### Now generate synthesis info for each submodule
  temp = subprocess.Popen("(cd "+toplevel+"; git submodule status)", stdout=subprocess.PIPE, shell=True)
  submodules = temp.stdout.read()
  submodules = submodules.split('\n')
  for module in submodules[:-1]:
    mod_splited = module.split()
    name = mod_splited[1].split('/')[-1]
    # if submodule is ahead of a set commit it displays additional _+_ at the
    # beginning, get rid of that:
    commit_id = mod_splited[0].translate(None, '+')[:32]
    # check if dirty
    dirty = False
    temp = subprocess.Popen("(cd "+toplevel+"/"+mod_splited[1]+ ";" + GIT_DIRTY +")",
        stdout=subprocess.PIPE, shell=True)
    if temp.stdout.read()[-2] == '+':
      dirty = True
    write_sdb_info(f, name, name, commit_id, dirty, " ", 0, 0, " ")

  f.write(PKG_TAIL)
  f.close()

if __name__ == '__main__':
  main()
