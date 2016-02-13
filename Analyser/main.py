import json
import sys
import glob
# import pprint

if __name__ == '__main__':
	# nameOfFile = sys.argv[1]
	files = glob.glob('*_zoom.json')

	# pprint.pprint(files)
	# for file in files:
	wpm_values = []
	for x in xrange(0,5):
		wpm_values.append([]);

	errors = []
	for x in xrange(0,5):
		errors.append(0);

	wordCounts = []
	for x in xrange(0,5):
		wordCounts.append(0);
	
	# countWPM = 0.0
	# countWord = 0
	# countSoftError = 0
	# countHardError = 0
	# countTotalError = 0

	for file in files:
		countData = 0
		# countWord = 0
		# errorCount = 0
		with open(file) as data_file:
			datas = json.load(data_file)

			for data in datas:
				print data['total_error'] /float(len(data['original_Text']))
				# print countData
				# wpm_values[countData % 5].append(data['WPM_value'])
				# errors[countData % 5] += int(data['hard_error'])
				# wordCounts[countData % 5] += len(data['original_Text'])
				# countData+= 1

				
					
				# wpm_values.append(data['WPM_value'])

				# countWPM += float(data['WPM_value'])
				# countWord += len(data['original_Text'])
				# errorCount += int(data['total_error'])
				 # += int(data['hard_error'])

				# countSoftError += int(data['soft_error'])
				# countTotalError += int(data['total_error'])
		# for value in wpm_values:
		# 	print value
		# print wpm_values
		# wpm_values.remove(max(wpm_values))
		# wpm_values.remove(min(wpm_values))
		# for vaule in wpm_values_to_remove:
			# wpm_values.remove(vaule)
	# for x in xrange(0,5):
		# print x
		# print "WPM:" + str(sum(wpm_values[x]) / float(len(wpm_values[x])))
		# print "Error:" + str(errors[x] / float(wordCounts[x]))

	# for WPM in 
	
	# print "WPM:" + str(countWPM/float(countData))
	# print "Error Rate(Total):" + str(countTotalError/float(countWord))
	# print "Error Rate(Hard):" + str(countHardError/float(countWord))
	# print "Error Rate(Soft):" + str(countSoftError/float(countWord))
			