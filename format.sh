find ./project -name '*.c' -o -name '*.cpp' -o -name '*.m' -o -name '*.mm' -o -name '*.h' -o -name '*.hpp' | xargs clang-format -i
haxelib run formatter -s hxserial_api > /dev/null