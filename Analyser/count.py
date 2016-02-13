import json
import sys
import glob

if __name__ == '__main__':
	nameOfFile = sys.argv[1]
	# files = glob.glob('*_force.json')


	# for file in files:
	wpm_values = []

	# for x in xrange(0,5):
	# 	wpm_values.append(0.0);
	countData = 0
	countWPM = 0.0
	countWord = 0
	countSoftError = 0
	countHardError = 0
	countTotalError = 0

	with open(nameOfFile) as data_file:
		datas = json.load(data_file)

		for data in datas:
			countData+= 1
			wpm_values.append(data['WPM_value'])
			countWPM += float(data['WPM_value'])
			countWord += len(data['original_Text'])
			countHardError += int(data['hard_error'])

			countSoftError += int(data['soft_error'])
			countTotalError += int(data['total_error'])
		# for value in wpm_values:
		# 	print value
		# print wpm_values
		# wpm_values.remove(max(wpm_values))
		# wpm_values.remove(min(wpm_values))
		# for vaule in wpm_values_to_remove:
			# wpm_values.remove(vaule)
		# print "WPM:" + str(sum(wpm_values) / float(len(wpm_values)))
	print "WPM:" + str(countWPM/float(countData))
	print "Error Rate(Total):" + str(countTotalError/float(countWord))
	print "Error Rate(Hard):" + str(countHardError/float(countWord))
	print "Error Rate(Soft):" + str(countSoftError/float(countWord))
			