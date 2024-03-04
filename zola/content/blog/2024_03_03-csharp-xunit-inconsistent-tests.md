+++
title = "C# - xUnit inconsistent tests"
date = 2024-03-03
+++

I am using dotnet ecosystem and mainly ASPNet core for the first time to build REST API and other platform components - had to adapt tech stack to fit other team members. Testing is important and I would like to unit test the REST API, to avoid any issue in future. While trying to set up xUnit I noticed the test results were inconsistent and the user experience is the worst, going from mostly Python Django where everything is implemented to work nicely together this was kind of painful experience.

After some research and rant searching on the internet I found this [reddit "rant"](https://www.reddit.com/r/dotnet/comments/enijsk/why_i_no_longer_use_xunit/) about xUnit and learned that all the tests are run in random order, parallel and with unrelated tests. So this is why sometimes the test failed and sometimes it didn't. I understand this decision but it makes integrating systems where the state is not under your full control hell, even more so if you are not familiar with the xUnit.

# Solution

I though that the xUnit calls the contructor automatically before each test like Python Django `unittest` does with `setUp()`, surprise surprise it does not. So the solution for me was to create separate `SetUp()` method that is called in each `[Fact]` on top and also to make sure the tests run sequentially and not in random order I had to add `[Collection("Sequential")]` attribute to the test class.

# Conclusion

Before actually working with the dotnet ecosystem I though that going from dynamically typed Python to statically typed C# will be great and make the project more sustainable, which I can't tell right now since the project is in early stages, but the ecosystem which is arguably the most important factor nowadays really sucks for dotnet. The language itself is great, just Java that does not suck that bad, but the Microsoft infested ecosystem and documentation is really bad. The Windows centric guides with screenshots from Visual Studio that are not usable for Linux system do not help either.

