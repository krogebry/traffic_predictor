#!/usr/bin/ruby
##
#
##

t = [0,11,0,0,5]

# 0: nil
# 1: green ( 00ff00 )
# 2: yellow ( ffdd00 )
# 3: pink ( ffcccc )
# 4: red ( ff0000 )

total = 0.0
t.map{|r| total += r }

baseColor = [255,255,255]

## green
#p = (255 - ((t[1].to_f / total)*255).to_i() )
p = (( t[1].to_f / total)*255)
puts "Green: #{p}"
baseColor[0] -= p.to_i()
baseColor[2] -= p.to_i()
puts baseColor.inspect

## yellow
p = (( t[2].to_f / total)*255)
puts "Yellow: #{p}"
baseColor[0] += (p*0.75).to_i()
baseColor[1] += (p*0.25).to_i()
baseColor[2] -= p.to_i()
puts baseColor.inspect

## pink
p = (( t[3].to_f / total)*255).to_i()
puts "Pink: #{p}"
#baseColor[0] += (p/2).to_i()
#baseColor[1] -= (p/3).to_i()
#baseColor[2] += (p/3).to_i()
puts baseColor.inspect

## red
p = (( t[4].to_f / total)*255)
puts "Red: #{p}"
baseColor[0] += p.to_i()
baseColor[1] -= p.to_i()
baseColor[2] -= p.to_i()
#baseColor[2] -= (p.to_f/2.0).to_i()
puts baseColor.inspect

baseColor.map!{|bc| (bc > 255 ? 255 : (bc < 0 ? 0 : bc )) }

puts baseColor.inspect
puts "Base: "+ baseColor[0].to_s( 16 ) + baseColor[1].to_s( 16 ) + baseColor[2].to_s( 16 ) 
