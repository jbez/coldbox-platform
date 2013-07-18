﻿<cfcomponent output="false" extends="coldbox.system.testing.BaseTestCase">
	
	<cfscript>
		this.loadColdBox = false;
	
		function setup(){
			test = getMockBox().createEmptyMock( "coldbox.testing.cases.testing.Test" );
		}
		
		function testMockRealMethods(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.Test" );
			test.getData();
			assertEquals( -1, test.$count( "getData" ) );
			test.$( "getData", 1000 );
			assertEquals( 0, test.$count( "getData" ) );
			test.getData();
			test.getData();
			assertEquals( 2, test.$count( "getData" ) );
		
			// With DSL
			test.$reset().$( "getData" ).$results( 1000 );
			assertEquals( 0, test.$count( "getData" ) );
			test.getData();
			test.getData();
			assertEquals( 2, test.$count( "getData" ) );
			assertEquals( 1000, test.getData() );
		}
		
		function testVirtualMethods(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.Test" );
			test.$( "virtualReturn" ).$results( 'Virtual Called Baby!!' );
			assertEquals( 0, test.$count( "virtualReturn" ) );
			assertEquals( "Virtual Called Baby!!", test.virtualReturn() );
			debug( test.$callLog() );
			assertTrue( structKeyExists( test.$callLog(), "virtualReturn" ) );
		}
		
		function testProperties(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.Test" );
			// reload original property value
			original = test.getReload();
			test.$property( propertyName="reload", propertyScope="variables", mock=true );
			assertEquals( true, test.getReload() );
		}
		
		function testMockPrivateMethods(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.Test" );
			name = test.getFullName();
			debug( name );
			test.$( "getName", "Mock Ruler" );
			assertEquals( "Mock Ruler", test.getFullName() );
		}
		
		function testSpys(){
			Test = createObject( "component", "coldbox.testing.cases.testing.Test" );
			getMockBox().prepareMock( test );
			// mock un-spy methods
			assertEquals( 5, test.getData() );
			assertEquals( 5, test.spyTest() );
			// spy the methods
			test.$( "getData" ).$results( 1000 );
			assertEquals( 1000, test.getData() );
			assertEquals( 0, test.spyTest() );
		}
		
		function testMockWithArguments(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.Test" );
			//unmocked
			assertEquals( "/mockFactory", test.getSetting( "AppMapping" ) );
			assertEquals( "NOT FOUND", test.getSetting( "DebugMode" ) );
		
			// Mock
			test.$( method='getSetting', callLogging=true ).$args( "AppMapping" ).$results( "mockbox.testing" );
			test.$( method='getSetting', callLogging=true ).$args( "DebugMode" ).$results( "true" );
			assertEquals( "mockbox.testing", test.getSetting( "AppMapping" ) );
			assertEquals( "true", test.getSetting( "DebugMode" ) );
		}
		
		function testCollaborator(){
			Test = createObject( "component", "coldbox.testing.cases.testing.Test" );
			mockCollaborator = getMockBox().createMock( className="coldbox.testing.cases.testing.Collaborator", 
		                                             callLogging=true );
		
			mockCollaborator.$( "getDataFromDB" ).$results( queryNew( "" ) );
			Test.setCollaborator( mockCollaborator );
			debug( mockCollaborator.$callLog() );
			assertEquals( queryNew( "" ), test.displayData() );
		}
		
		function testStateMachineResults(){
			Test = getMockBox().createMock( "coldbox.testing.cases.testing.Test" );
			test.$( "getSetting" ).$results( "S1", "S2", "S3" );
		
			assertEquals( "S1", test.getSetting() );
			assertEquals( "S2", test.getSetting() );
			assertEquals( "S3", test.getSetting() );
			assertEquals( "S1", test.getSetting() );
			assertEquals( "S2", test.getSetting() );
		}
		
		function testStubs(){
			stub = getMockBox().createStub().$( "getName", "Luis Majano" );
			assertEquals( "Luis Majano", stub.getName() );
		}
		
		function testVerifyOnce(){
			test.$( "displayData", queryNew( '' ) ).$( "testIt" ).$( "testNone" );
			test.testIt();
			assertTrue( test.$once() );
			test.displayData();
			assertTrue( test.$once( "displayData" ) );
		
			assertFalse( test.$once( "testNone" ) );
		}
		
		function testVerifyNever(){
			test.$( "displayData", queryNew( '' ) );
			test.$( "testIt" );
			assertTrue( test.$never() );
			test.testIt();
			assertTrue( test.$never( "displayData" ) );
			test.displayData();
			assertFalse( test.$never( "displayData" ) );
		}
		
		function testVerifyAtMost(){
			test.$( "displayData", queryNew( '' ) );
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			assertFalse( test.$atMost( 3 ) );
			assertTrue( test.$atMost( 5 ) );
		}
		
		function testVerifyAtLeast(){
			test.$( "displayData", queryNew( '' ) );
			assertTrue( test.$atLeast( 0 ) );
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			test.displayData();
			assertTrue( test.$atLeast( 3 ) );
		}
		
		function testVerifyCallCount(){
			test.$( "displayData", queryNew( '' ) );
			assertTrue( test.$verifyCallCount( 0 ) );
			assertFalse( test.$verifyCallCount( 1 ) );
		
			test.displayData();
			assertEquals( true, test.$verifyCallCount( 1 ) );
		
			test.displayData();
			test.displayData();
			test.displayData();
			assertEquals( true, test.$verifyCallCount( 4 ) );
			assertEquals( true, test.$verifyCallCount( 4, "displayData" ) );
		}
		
		function testMockMethodCallCount(){
			test.$( "displayData", queryNew( '' ) );
			test.$( "getLuis", 1 );
		
			assertEquals( 0, test.$count( "displayData" ) );
			assertEquals( -1, test.$count( "displayData2" ) );
		
			test.displayData();
		
			assertEquals( 1, test.$count( "displayData" ) );
		
			test.getLuis();
			test.getLuis();
			assertEquals( 3, test.$count() );
		}
		
		function testMethodArgumentSignatures(){
			
			args = {
				string = "test" // string
				,integer = 23 // integer
				,xmlDoc = xmlNew()
				,query = queryNew('')
				,datetime = now()
				,boolean = true
				,realNumber = 2.5
				,structure = {key1 = 'value1',key2 = getMockBox().createStub()}
				,array = ['element1', getMockBox().createStub()]
				,object = getMockBox().createStub()
			};
			
			//1: Mock with positional and all calls should validate.
			test.$( "getSetting" )
				.$args( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object )
				.$results( "UnitTest" );
		
			// Test positional
			results = test.getSetting( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object );
			assertEquals( "UnitTest", results );
			// Test case sensitivity
			args.string = "TEST";
			results = test.getSetting( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object );
			assertEquals( "UnitTest", results );
			args.string = "test";
			// Test increment/decrement value (ColdFusion bug converts integers to real numbers with increment and decrement operator)
			args.integer++; args.integer--;
			results = test.getSetting( args.string, args.integer, args.xmlDoc, args.query, args.datetime, args.boolean, args.realNumber, args.structure, args.array, args.object );
			assertEquals( "UnitTest", results );
			args.integer = 23;
			args.integer = 23;
			
			//2. Mock with named values and all calls should validate.
			test.$( "getSetting" ).$args( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object ).$results( "UnitTest2" );
			
			// Test name-value pairs
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			assertEquals( "UnitTest2", results );
			// Test argCollection
			results = test.getSetting( argumentCollection=args );
			assertEquals( "UnitTest2", results );
			// Test case sensitivity
			args.string = "TEST";
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			assertEquals( "UnitTest2", results );
			args.string = "test";
			// Test increment/decrement value (ColdFusion bug converts integers to real numbers with increment and decrement operator)
			args.integer++;args.integer--;
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			assertEquals( "UnitTest2", results );
			args.integer = 23;
			
			test.$( "getSetting" ).$args( argumentCollection=args ).$results( "UnitTest3" );
			// Test name-value pairs
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			assertEquals( "UnitTest3", results );
			// Test argCollection
			results = test.getSetting( argumentCollection=args );
			assertEquals( "UnitTest3", results );
			// Test case sensitivity
			args.string = "TEST";
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			assertEquals( "UnitTest3", results );
			args.string = "test";
			// Test increment/decrement value (ColdFusion bug converts integers to real numbers with increment and decrement operator)
			args.integer++;args.integer--;
			results = test.getSetting( string=args.string, integer = args.integer, xmlDoc = args.xmlDoc, query = args.query, datetime = args.datetime, boolean = args.boolean, realNumber = args.realNumber, struct = args.structure, array = args.array, object = args.object );
			assertEquals( "UnitTest3", results );
		}
		
		function testGetProperty(){
			mock = getMockBox().createStub();
			mock.luis = "Majano";
			mock.$property( "cool", "variables", true ).$property( "number", "variables.instance", 7 );
		
			assertEquals( "Majano", mock.$getProperty( name="luis", scope="this" ) );
			assertEquals( true, mock.$getProperty( name="cool" ) );
			assertEquals( true, mock.$getProperty( name="cool", scope="variables" ) );
			assertEquals( 7, mock.$getProperty( name="number", scope="variables.instance" ) );
			assertEquals( 7, mock.$getProperty( name="number", scope="instance" ) );
		}
		
		function testStubWithInheritance(){
			mock = getMockBox().createStub( extends="coldbox.system.EventHandler" );
			assertTrue( isInstanceOf( mock, "coldbox.system.EventHandler" ) );
		}
		
		function testStubWithImplements(){
			mock = getMockBox().createStub( implements="coldbox.system.cache.ICacheProvider" );
			assertTrue( isInstanceOf( mock, "coldbox.system.cache.ICacheProvider" ) );
		}
		
		function testContainsCFKeyword(){
			test = getMockBox().createMock("coldbox.testing.cases.testing.Test");
			mockTest = getMockBox().createEmptyMock( "coldbox.testing.cases.testing.ContainsTest" )
				.$("contains", true);
			assertTrue( mockTest.contains() );
		}
		
		function testContainsClosureOrUDF(){
			mock = getMockBox().createStub();
			mock.$("mockMe", "Mocked" );
			
			assertEquals( "Mocked" , mock.mockMe( variables.testFunction ) );
			assertEquals( "Mocked" , mock.mockMe( test = variables.testFunction ) );
			assertEquals( "Mocked" , mock.mockMe( [ variables.testFunction ] ) );
			assertEquals( "Mocked" , mock.mockMe( test = [ variables.testFunction ] ) );
			assertEquals( "Mocked" , mock.mockMe( { mockData = variables.testFunction } ) );
			assertEquals( "Mocked" , mock.mockMe( test = { mockData = variables.testFunction } ) );
		}
		
		private function testFunction(){
			return "Hola Amigo!";
		}
	</cfscript>

</cfcomponent>