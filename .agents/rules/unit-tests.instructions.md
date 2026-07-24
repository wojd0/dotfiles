When writing unit tests in agentic mode, keep running tests in affected files until all tests pass.

Reduce formatting and focus on clear and concise tests.

Do not create should create test cases.

Use empty lines to separate arrange, act, and assert.

When testing rxjs use firstValueFrom or lastValueFrom with async and await instead of subscribe.

Do not use TestBed.resetTestingModule.

Do not overuse fakeAsync, fixture.detectChanges, fixture.whenStable, or other time ticking methods.

Do not use done callbacks.

Do not put await inside expect; extract awaited values first.

Use a shared setupTest function with a configuration object and sensible defaults.

If in hxp-frontend-apps, use libs/shared/testing/src/util/component-harnesses for Angular Material components.
