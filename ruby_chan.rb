#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class Brainfuck
  def initialize(options = {})
    self.class.default_mapping.each do |key, default|
      operations[key] = options.has_key?(key) ? options[key] : default
    end
  end

  def self.bf_mapping
    @bf_operations ||= {nxt: '>', prv: '<', inc: '+', dec: '-', put: '.',  get: ',', opn: '[', cls: ']' }
  end

  def self.default_mapping
    @default_mapping ||= bf_mapping.clone
  end

  def operations
    @operations ||= {}
  end

  default_mapping.keys.each do |op|
    define_method(op) do
      instance_variable_get(:@operations)[op]
    end
  end

  def compile(src)
    Brainfuck.new.translate(self, src)
  end

  def translate(other, src)
    other = other.new if other.kind_of?(Class)
    cur = 0
    inv = other.operations.invert
    reg = Regexp.compile "(#{other.operations.values.map{|v| Regexp.quote(v) }.join('|')})"
    dst = ''
    while matches = reg.match(src, cur)
      op = inv[matches[1]]
      dst += operations[op]
      cur = src.index(reg, cur) + matches[1].length
    end
    dst
  end

  def hello_world
    translate(Brainfuck, '>+++++++++[<++++++++>-]<.>+++++++[<++++>-]<+.+++++++..+++.[-]>++++++++[<++++>-]<.>+++++++++++[<+++++>-]<.>++++++++[<+++>-]<.+++.------.--------.[-]>++++++++[<++++>-]<+.[-]++++++++++.')
  end

  def fuck(src)
    src = compile(src)

    memory = Array.new(3000,0)
    ptr = 0
    cur = 0
    while cur<src.length do
      case src[cur]
        when '<' then
          ptr -= 1
        when '>' then
          ptr += 1
        when '+' then
          memory[ptr] += 1
        when '-' then
          memory[ptr] -= 1
        when ',' then
          memory[ptr] = STDIN.getc.ord
        when '.' then
          print memory[ptr].chr
        when '[' then
          if memory[ptr]==0 then
            loop_count = 0
            while true do
              cur += 1
              if src[cur]=='[' then
                loop_count += 1
              elsif src[cur]==']' then
                if loop_count==0 then
                  break
                else
                  loop_count -= 1
                end
              end
            end
          end
        when ']' then
          if memory[ptr]!=0 then
            loop_count = 0
            while true do
              cur -= 1
              if src[cur]==']' then
               loop_count += 1
              elsif src[cur]=='[' then
                if loop_count==0 then
                  break
                else
                  loop_count -= 1
                end
              end
            end
          end
    end
    cur += 1
    end
  end

  class << self
    Brainfuck.default_mapping.keys.each do |op|
      define_method(op) do |val|
        default_mapping[op] = val
      end
    end
  end
end

# For backwards compatibility.
BrainFuck = Brainfuck

class RubyK < Brainfuck
  nxt "おねいちゃあ…"
  prv "りあちゃあ…"
  inc "ぅゅ…"
  dec "ぅゅゅ…"
  opn "ピギィ！"
  cls "ピギャア！"
  put "がんばルビィ！"
  get "ふんばルビィ！"
end

RubyK.new.fuck(ARGF.read)