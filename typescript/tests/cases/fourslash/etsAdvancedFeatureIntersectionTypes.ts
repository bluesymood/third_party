/// <reference path='./fourslash.ts' />

// @experimentaldecorators: true
// @ets: {}
// @target: es6
// @lib: es6

// @Filename: test.ets
//// class T1{
//// }
//// class T2{
//// }
//// @Entry
//// @Component
//// struct MyComponent1{
////     build() {
////     }
////     /*2*/func1(params:string) :T1 & T2{
////         return ""
////     }
//// }
//// @Component
//// struct ParentComponent1{
////     build(){
////        MyComponent1().[|/*1*/func1|]("1")
////     }
//// }

verify.noErrors();
verify.completions({ marker: "1", includes: "func1" });
verify.goToDefinition("1", "2");
