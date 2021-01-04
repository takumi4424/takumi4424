#coding:utf-8

import re
from PIL import Image, ImageDraw

class OBJ2D:
	def __init__(self, layer, space, handle):
		self.layer = layer
		self.space = space
		self.handle = handle

class ARC(OBJ2D):
	acad_pat = re.compile(
		r'^\s*center\s*point,\s*X=\s*(?P<x>-?\d*\.?\d*)\s*Y=\s*(?P<y>-?\d*\.?\d*)\s*Z=\s*(?P<z>-?\d*\.?\d*)\s*\n'
		r'\s*radius\s*(?P<radius>-?\d*\.?\d*)\s*\n'
		r'\s*start angle\s*(?P<startangle>-?\d*\.?\d*)\s*\n'
		r'\s*end angle\s*(?P<endangle>-?\d*\.?\d*)\s*\n'
		r'\s*length\s*(?P<length>-?\d*\.?\d*)\s*$'
		, re.MULTILINE)

	def set_data(self, x, y, z, radius, startangle, endangle):
		self.center = (x, y, z)
		self.radius = radius
		self.startangle = startangle
		self.endangle = endangle

	def set_data_from_acad(self, str):
		match = ARC.acad_pat.search(str)
		self.set_data(
			float(match.group('x')),
			float(match.group('y')),
			float(match.group('z')),
			float(match.group('radius')),
			float(match.group('startangle')),
			float(match.group('endangle')))

	def draw(self, draw, offset=(0,0), scale=1.0):
		# original
		x, y, z = self.center
		rad = self.radius
		# modify
		x_off, y_off = offset
		x = x*scale + x_off
		y = y*scale + y_off
		rad *= scale
		# make data
		x0 = int(x-rad)
		y0 = int(y-rad)
		x1 = int(x+rad)
		y1 = int(y+rad)
		start = int(self.startangle)
		end = int(self.endangle)
		# draw
		draw.arc([(x0,y0), (x1,y1)], start, end)

class LINE(OBJ2D):
	acad_pat = re.compile(
		r'\s*from\s*point,\s*X=\s*(?P<x1>-?\d*\.?\d*)\s*Y=\s*(?P<y1>-?\d*\.?\d*)\s*Z=\s*(?P<z1>-?\d*\.?\d*)\s*\n'
		r'\s*to\s*point,\s*X=\s*(?P<x2>-?\d*\.?\d*)\s*Y=\s*(?P<y2>-?\d*\.?\d*)\s*Z=\s*(?P<z2>-?\d*\.?\d*)\s*\n'
		r'\s*Length\s*=\s*(?P<length>-?\d*\.?\d*)\s*,\s*Angle\s*in\s*XY\s*Plane\s*=\s*(?P<angleinxy>-?\d*\.?\d*)\s*\n'
		r'\s*Delta\s*X\s*=\s*(?P<deltax>-?\d*\.?\d*)\s*,\s*Delta\s*Y\s*=\s*(?P<deltay>-?\d*\.?\d*)\s*,\s*Delta\s*Z\s*=\s*(?P<deltaz>-?\d*\.?\d*)\s*$'
		, re.MULTILINE)

	def set_data(self, x1, y1, z1, x2, y2, z2):
		self.frompoint = (x1, y1, z1)
		self.topoint = (x2, y2, z2)

	def set_data_from_acad(self, str):
		match = LINE.acad_pat.search(str)
		self.set_data(
			float(match.group('x1')),
			float(match.group('y1')),
			float(match.group('z1')),
			float(match.group('x2')),
			float(match.group('y2')),
			float(match.group('z2')))

	def draw(self, draw, offset=(0,0), scale=1.0):
		lines = []
		for point in [self.frompoint, self.topoint]:
			# original
			x, y, z = point
			# modify
			x_off, y_off = offset
			x = x*scale + x_off
			y = y*scale + y_off
			# add point
			lines.append((int(x), int(y)))
		# draw
		draw.line(lines)

class CIRCLE(OBJ2D):
	acad_pat = re.compile(
		r'^\s*center\s*point,\s*X=\s*(?P<x>-?\d*\.?\d*)\s*Y=\s*(?P<y>-?\d*\.?\d*)\s*Z=\s*(?P<z>-?\d*\.?\d*)\s*\n'
		r'\s*radius\s*(?P<radius>-?\d*\.?\d*)\s*\n'
		r'\s*circumference\s*(?P<circumference>-?\d*\.?\d*)\s*\n'
		r'\s*area\s*(?P<area>-?\d*\.?\d*)\s*\n'
		, re.MULTILINE)

	def set_data(self, x, y, z, radius):
		self.center = (x, y, z)
		self.radius = radius

	def set_data_from_acad(self, str):
		match = CIRCLE.acad_pat.search(str)
		self.set_data(
			float(match.group('x')),
			float(match.group('y')),
			float(match.group('z')),
			float(match.group('radius')))

	def draw(self, draw, offset=(0,0), scale=1.0):
		# original
		x, y, z = self.center
		rad = self.radius
		# modify
		x_off, y_off = offset
		x = x*scale + x_off
		y = y*scale + y_off
		rad *= scale
		# make data
		x0 = int(x-rad)
		y0 = int(y-rad)
		x1 = int(x+rad)
		y1 = int(y+rad)
		start = 0
		end = 360
		# draw
		draw.arc([(x0,y0), (x1,y1)], start, end)

class LWPOLYLINE(OBJ2D):
	acad_pat = re.compile(
		r'^\s*at\s*point\s*X=\s*(?P<x>-?\d*\.?\d*)\s*Y=\s*(?P<y>-?\d*\.?\d*)\s*Z=\s*(?P<z>-?\d*\.?\d*)\s*$'
		, re.MULTILINE)

	def set_data(self, points):
		self.points = points

	def set_data_from_acad(self, str):
		points = []

		for m in LWPOLYLINE.acad_pat.finditer(str):
			point = (
				float(m.group(x)),
				float(m.group(y)),
				float(m.group(z)))
			points.append(point)

		self.set_data(points)

	def draw(self, draw, offset=(0,0), scale=1.0):
		lines = []
		for point in self.points:
			# original
			x, y, z = point
			# modify
			x_off, y_off = offset
			x = x*scale + x_off
			y = y*scale + y_off
			# add point
			lines.append((int(x), int(y)))
		# draw
		draw.line(lines)

if __name__ == '__main__':

	# img = Image.open('sample.jpg')
	img = Image.new('RGB', (72, 72), (255, 255, 255))
	img = img.convert('L')
	draw = ImageDraw.Draw(img)

	objs = []

	f = open('alpaca.txt', 'r')

	obj_pat = re.compile(
		r'\s*(?P<type>LINE|ARC|CIRCLE|LWPOLYLINE)+\s*Layer:\s*(?P<layer>.*?)\s*\n'
		r'\s*Space:\s*(?P<space>.*?)\s*\n'
		r'\s*Handle\s*=\s*(?P<handle>\w+)\s*\n'
		r'(?P<data>(?:.*\n)*?)'
		r'\s*(?=LINE|ARC|CIRCLE|LWPOLYLINE|$)'
		, re.MULTILINE)
		# r'(.*\n)*?'

	for m in obj_pat.finditer(f.read()):
		obj = None
		obj_type = m.group('type')
		if obj_type == 'LINE':
			obj = LINE(m.group('layer'), m.group('space'), m.group('handle'))
		elif obj_type == 'ARC':
			obj = ARC(m.group('layer'), m.group('space'), m.group('handle'))
		elif obj_type == 'CIRCLE':
			obj = CIRCLE(m.group('layer'), m.group('space'), m.group('handle'))
		elif obj_type == 'LWPOLYLINE':
			obj = LWPOLYLINE(m.group('layer'), m.group('space'), m.group('handle'))

		obj.set_data_from_acad(m.group('data'))
		obj.draw(draw, offset=(36, 30), scale=2.5)


	img = img.transpose(Image.ROTATE_180)
	# img.show()
	img.save('/root/LogoMaker/hoge.png')

	# print(i)
