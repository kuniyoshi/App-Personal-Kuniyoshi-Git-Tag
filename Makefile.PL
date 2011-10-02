use inc::Module::Install;
name 'App-Personal-Kuniyoshi-Git-Tag';
all_from 'lib/App/Personal/Kuniyoshi/Git/Tag.pm';

requires 'Readonly';
requires 'Path::Class';
requires 'Time::Piece';

install_script "bin/apk-git-tag";

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
