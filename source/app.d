import std.stdio;
import bottomify;

void main()
{
	string helloWorld = "💖✨✨,,👉👈💖💖,👉👈💖💖🥺,,,👉👈💖💖🥺,,,👉👈💖💖✨,👉👈✨✨✨,,👉👈💖✨✨✨🥺,,👉👈💖💖✨,👉👈💖💖✨,,,,👉👈💖💖🥺,,,👉👈💖💖👉👈✨✨✨,,,👉👈";
	assert(encode("Hello World!") == helloWorld);
	assert(decode(helloWorld) == "Hello World!");
	writeln("Tests passed.");
}
