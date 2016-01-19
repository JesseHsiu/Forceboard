import sys
import numpy as np

def main():

	isForceTouch = False

	force = 0.0
	forceCount = 0

	slight = 0.0
	slightCount = 0

	if len(sys.argv) == 2:
		with open(sys.argv[1]) as f:
			for line in f:
				
				data = []
				for value in line.split(',')[0:-1]:
					data.append(float(value))

				if isForceTouch:
					print "force: " + str(np.var(np.array(data)))
					force += np.var(np.array(data))
					forceCount += 1
				else:
					print "slight: " + str(np.var(np.array(data)))
					slight += np.var(np.array(data))
					slightCount +=1
				isForceTouch = ~isForceTouch
			# print f.readline()
		print "avg Force: " + str(force/forceCount)
		print "avg Slight: " + str(slight/slightCount)
	else:
		print "please enter two argument"


if __name__ == '__main__':
	main()