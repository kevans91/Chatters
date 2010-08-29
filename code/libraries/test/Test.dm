/**************************
 * Deadron's Test library *
 **************************

 This is the entirety of the test framework.
 You create tests using the rules below, and
 the framework runs them for you.

 It simply provides the dd_run_tests() proc for you to call,
 which automatically runs all tests that are part of the
 /obj/test object.

 If the DEBUG flag is set the tests will be run automatically when
 the game starts up. You can set the DEBUG flag either by turning on
 "Generate debugging information" in Build->Preferences, or using:

 #define DEBUG

 For tests to work, there are three simple requirements:

 1) All the tests must be defined as verbs on the test object, such as:

	obj/test/verb/mytest()

 2) When a test fails, it should call the test object's die() proc:

	obj/test/verb/isValidName_test()
		if (!isValidName("Deadron"))
			die("isValidName() didn't allow legal name: Deadron")

    To see the tests in action, you can run the library, which will start up
    the demo code. See demo/Tests.dm for an example of simple and complex
    tests.

 3) To make sure your tests never collide with someone else's tests, you can
    use your own subclass of the test object, like so:

    obj/test/MyClass/verb/isValidName_test()
 		if (!isValidName("Deadron"))
			die("isValidName() didn't allow legal name: Deadron")

    The library will automatically find your class and execute the tests.

 If you have code that should be skipped or behave differently while tests are running,
 you can check if dd_testing = 1 or not.

 If you have comments or suggestions, email ron@deadron.com.
*/

#ifdef DEBUG
world
	New()
		// spawn() to increase chance of seeing success message; otherwise it happens before you can see it.
		spawn(5)
			dd_run_tests()
		return ..()
#endif

var/dd_testing

proc/dd_run_tests()
	// Test subclasses inherit ancestor tests...so keep track of each test called to make sure it's
	// not called multiple times due to subclasses. This is done with an associative list.
	dd_testing = 1
	var/test_classes = typesof(/obj/test)
	var/list/called = list()

	for (var/class in test_classes)
		var/obj/test/tester = new class()

		for (var/test in tester.verbs)
			if (called[test])
				continue

			call(tester, test)()

			if (!tester.success)
				dd_testing = 0
				world << "Test failed: [test]"
				return

			called[test] = test

	dd_testing = 0
	world << "All tests passed."


obj/test
	var/success = 1

	proc/die(message)
		success = 0
		world << message
		CRASH(message)