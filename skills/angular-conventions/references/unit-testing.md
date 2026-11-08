# Unit testing rules

- In agentic mode, run the tests in the affected files until all tests pass.
- Cover a behavior in each test case. Do not write "should create" test cases.
- Separate arrange, act, and assert with empty lines.
- Test RxJS code with `firstValueFrom` or `lastValueFrom`, with `async` and `await`.
- Use `async` and `await` for asynchronous tests.
- Rely on the automatic TestBed reset between tests.
- Use `fakeAsync`, `fixture.detectChanges`, `fixture.whenStable`, and time ticking methods only when no simpler way works.
- Extract awaited values to variables first. Pass the variables to `expect()`.
- Use one shared `setupTest` function. Give it a configuration object argument with sensible defaults. Share it across all `describe` blocks.
- In hxp-frontend-apps, use `libs/shared/testing/src/util/component-harnesses` for Angular Material components.
- Let errors reach the test runner.
- Keep tests clear and concise.
