#!/usr/bin/env ruby
gem 'table_print', '>= 1.5.6'
require 'table_print'

table = {
  JP1_L2TP:"p2.jp1.talkhide.com",
  JP1_IKEv2:"p4.jp1.talkhide.com",
  JP2_L2TP:"p2.jp2.talkhide.com",
  JP2_IKEv2:"p4.jp2.talkhide.com",
  JP3_L2TP:"p2.jp3.talkhide.com",
  JP3_IKEv2:"p4.jp3.talkhide.com",
  JP4_L2TP:"p2.jp4.talkhide.com",
  JP4_IKEv2:"p4.jp4.talkhide.com",
  TW1_L2TP:"p2.tw1.talkhide.com",
  TW1_IKEv2:"p4.tw1.talkhide.com",
  HK1_L2TP:"p2.hk1.talkhide.com",
  HK1_IKEv2:"p4.hk1.talkhide.com",
  HK2_L2TP:"p2.hk2.talkhide.com",
  HK2_IKEv2:"p4.hk2.talkhide.com", 
  HK3_L2TP:"p2.hk3.talkhide.com",
  HK3_IKEv2:"p4.hk3.talkhide.com", 
}

class VPNNode
  attr_reader :name, :ip, :max_resp_time, :avg_resp_time, :min_resp_time, :lost_percentage

  def initialize(name, ip)
    @ip = ip
    @name = name
  end

  def ping
    pkg_stat, pkg_time = %x(ping -c 5 #{@ip}).split(/[\n]/).last(2)

    if pkg_stat && pkg_time
      @lost_percentage = pkg_stat.scan(/\d+.\d+%/).first
      @min_resp_time, @avg_resp_time, @max_resp_time = pkg_time.scan(/\d+.\d+/)
    end
  end
end


class Checker
  def initialize(ips)
    @ipns = ips.map{|name, ip| VPNNode.new(name, ip)}
  end

  def ping
    threads = []
    @ipns.each {|ipn| threads << Thread.new { ipn.ping }}
    threads.each{|tr| tr.join }
  end

  def stat
    tp @ipns, :name, :ip, :max_resp_time, :avg_resp_time, :min_resp_time, :lost_percentage
  end
end

checker = Checker.new(table)
checker.ping
checker.stat