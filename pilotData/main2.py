import sys
import numpy as np
import glob
import os

def main():

	isForceTouch = False

	if len(sys.argv) == 1:

		# ======= SPLIT FILES ======
		files = glob.glob('*.txt')
		# print files
		for file in files:
			forceData = []
			slightData = []

			with open(file) as f:	
				for line in f:
					# print line
					data = []
					for value in line.split(',')[0:-1]:
						data.append(float(value))
					step = len(data)/30.0

					# finalData = []
					# current_step = 0.0
					# for x in xrange(0,30):
					# 	finalData.append(data[int(current_step)])
					# 	current_step+= step

					# print data
					if isForceTouch:
						if len(data) < 15:
							print "error"
						forceData.append(data)
					else:
						if len(data) > 15:
							print "error2"
						slightData.append(data)
					isForceTouch = ~isForceTouch

			name = file.split('.')[0]
			with open( "./force/" + name +'.txt', 'w') as f:
				for data in forceData:
					f.write(str(data).strip('[]') + '\n')
			with open( "./slight/" + name + '.txt', 'w') as f:
				for data in slightData:
					f.write(str(data).strip('[]') + '\n')

		# ======= NORMALIZE FILES ======
		forcefiles = glob.glob('./force/*.txt')
		slightfiles = glob.glob('./slight/*.txt')

		for x in xrange(0,len(forcefiles)):
			if not os.path.exists('./force/evaluate/user_' + str(x)+'/'):
			    os.makedirs('./force/evaluate/user_' + str(x)+'/')
			for y in xrange(0,len(forcefiles)):
				if y == x:
					with open('./force/evaluate/user_' + str(x) + '/predict.txt', 'a') as f:
						with open(forcefiles[y]) as r:
							for line in r:
								f.write(line);
				else:
					with open('./force/evaluate/user_' + str(x) + '/train.txt', 'a') as f:
						with open(forcefiles[y]) as r:
							for line in r:
								f.write(line);

		for x in xrange(0,len(slightfiles)):
			if not os.path.exists('./slight/evaluate/user_' + str(x)+'/'):
			    os.makedirs('./slight/evaluate/user_' + str(x)+'/')
			for y in xrange(0,len(slightfiles)):
				if y == x:
					with open('./slight/evaluate/user_' + str(x) + '/predict.txt', 'a') as f:
						with open(slightfiles[y]) as r:
							for line in r:
								f.write(line);
				else:
					with open('./slight/evaluate/user_' + str(x) + '/train.txt', 'a') as f:
						with open(slightfiles[y]) as r:
							for line in r:
								f.write(line);
			

	else:
		print "please enter two argument"


if __name__ == '__main__':
	main()