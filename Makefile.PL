use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME' => 'Syndication::ESF',
	'VERSION_FROM' => 'ESF.pm',
	'PREREQ_PM'    => {
		'Test::More' => 0
	},
);
