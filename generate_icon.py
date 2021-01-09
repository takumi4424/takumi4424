#!/usr/bin/env python3
# coding: utf-8

import re
from PIL import Image, ImageDraw
import yaml, sys, subprocess

def draw_arc(draw: ImageDraw.ImageDraw, target, offset=(0,0), scale=1.0):
	# check
	# calc
	x0 = (target['center']['x'] - target['radius']) * scale + offset[0]
	x1 = (target['center']['x'] + target['radius']) * scale + offset[0]
	y0 = (target['center']['y'] - target['radius']) * scale + offset[1]
	y1 = (target['center']['y'] + target['radius']) * scale + offset[1]
	start = target['range']['start']
	end = target['range']['end']
	# draw
	draw.arc(
		[(int(x0), int(y0)), (int(x1), int(y1))],
		start, end)

def draw_line(draw: ImageDraw.ImageDraw, target, offset=(0,0), scale=1.0):
	vertexes = []
	for vertex in target['vertexes']:
		x = vertex['x'] * scale + offset[0]
		y = vertex['y'] * scale + offset[1]
		vertexes.append((int(x), int(y)))
	# draw
	draw.line(vertexes)

if __name__ == '__main__':
	width = 72
	height = 72
	background = (0, 0, 0, 0)
	mode = 'RGBA'
	input = 'alpaca.yaml'
	output = 'hoge.png'

	with open('alpaca.yaml') as f:
		yml = yaml.safe_load(f)
	# print(yml)

	img = Image.new(mode, (width, height), background)
	draw = ImageDraw.Draw(img)

	for draw_target in yml['draws']:
		if draw_target['type'] == 'ARC':
			draw_arc(draw, draw_target, (36, 30), 2.5)
		elif draw_target['type'] == 'LINE':
			draw_line(draw, draw_target, (36, 30), 2.5)

	img = img.transpose(Image.ROTATE_180)

	img.save(output)
