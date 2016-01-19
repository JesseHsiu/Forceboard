var svm = require('node-svm');
var fs = require('fs');
var glob = require("glob");
var so = require('stringify-object');


var slight = glob.sync('./slight/evaluate/*').sort();
var force = glob.sync('./force/evaluate/*').sort();
console.log(force);

for (var i = 0; i < slight.length; i++) {
	
	var alltrainData = []

	var content = fs.readFileSync(slight[i]+'/train.txt','utf8').split('\n');

	for (var j = 0; j < content.length-1; j++) {
		alltrainData.push([content[j].split(',').map(Number), 0])
	};


	var content2 = fs.readFileSync(force[i]+'/train.txt','utf8').split('\n');

	for (var j = 0; j < content.length-1; j++) {
		alltrainData.push([content[j].split(',').map(Number), 1])
	};

	var clf = new svm.CSVC();

	clf.train(alltrainData)
		.progress(function(progress){
			console.log('training progress: %d%' ,Math.round(progress*100));
		})
		.spread(function (model, report) {
			console.log('training report: %s', so(report['accuracy']));
		});
};



