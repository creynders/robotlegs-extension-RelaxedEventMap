//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.relaxedEventMap.impl
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.instanceOf;
	import robotlegs.bender.extensions.relaxedEventMap.support.SampleEvent;

	public class RelaxedEventMapTest
	{

		/*============================================================================*/
		/* Public Static Properties                                                   */
		/*============================================================================*/

		public static const NULL_HANDLER:Function = function(event:Event):void {
		};

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var subject:RelaxedEventMap;

		private var eventDispatcher:EventDispatcher;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			eventDispatcher = new EventDispatcher();
			subject = new RelaxedEventMap(eventDispatcher);
		}

		[After]
		public function tearDown():void
		{
			subject = null;
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function instance_of_relaxedEventMap():void
		{
			assertThat(subject, instanceOf(RelaxedEventMap));
		}

		[Test]
		public function doesnt_throw_error_when_mapping():void
		{
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, function():void {
			}, SampleEvent, null, false, 0, true);
			// note: no assertion. we just want to know if an error is thrown
		}

		[Test]
		public function listener_called_after_the_fact():void
		{
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, NULL_HANDLER, SampleEvent);
			eventDispatcher.dispatchEvent(new SampleEvent(SampleEvent.SOMETHING_HAPPENED));
			var actual:String;
			var handler:Function = function(event:SampleEvent):void {
				actual = event.type;
			}
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, handler, SampleEvent);
			assertThat(actual, equalTo(SampleEvent.SOMETHING_HAPPENED));
		}

		[Test]
		public function unmapListener_unmaps_relaxed_listener():void
		{
			var called:Boolean = false;
			var handler:Function = function(event:SampleEvent):void {
				called = true;
			};
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, handler, SampleEvent);
			subject.unmapListener(eventDispatcher, SampleEvent.SOMETHING_HAPPENED, handler, SampleEvent);
			eventDispatcher.dispatchEvent(new SampleEvent(SampleEvent.SOMETHING_HAPPENED));
			assertThat(called, equalTo(false));
		}

		[Test]
		public function unmapRelaxedListener_unmaps_relaxed_listener():void
		{
			var called:Boolean = false;
			var handler:Function = function(event:SampleEvent):void {
				called = true;
			};
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, handler, SampleEvent);
			subject.unmapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, handler, SampleEvent);
			eventDispatcher.dispatchEvent(new SampleEvent(SampleEvent.SOMETHING_HAPPENED));
			assertThat(called, equalTo(false));
		}

		[Test]
		public function remembers_event():void
		{
			subject.rememberEvent(SampleEvent.SOMETHING_HAPPENED, SampleEvent);
			eventDispatcher.dispatchEvent(new SampleEvent(SampleEvent.SOMETHING_HAPPENED));
			var called:Boolean = false;
			var handler:Function = function(event:Event):void {
				called = true;
			}
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, handler, SampleEvent);
			assertThat(called, equalTo(true));
		}

//
//		/* not required - realised we need to keep the dummy listener throughout
//		for cases where the view is off stage for a while before returning
//
//		public function test_rememberEvent_listener_is_cleaned_up():void {
//		    instance.rememberEvent(SampleEventA.SOMETHING_HAPPENED, SampleEventA);
//	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
//	    	eventDispatcher.dispatchEvent(new SampleEventA(SampleEventA.SOMETHING_HAPPENED));
//	    	// unfortunately because the listener is by design empty, I can't find a way to test this automatically
//			// so it's a trace based confirmation
//			assertTrue("Manually verified that when a trace is placed in the null function used it doesn't trace", true);
//	    }    */
//

		[Test]
		public function removes_listeners_for_an_owner_object():void
		{
			var owner:Object = {};
			var called:Boolean = false;
			var handler:Function = function(event:Event):void {
				called = true;
			};
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, handler, SampleEvent, owner);
			subject.unmapListenersFor(owner);
			eventDispatcher.dispatchEvent(new SampleEvent(SampleEvent.SOMETHING_HAPPENED));
			assertThat(called, equalTo(false));
		}

		[Test]
		public function removing_listeners_for_an_owner_does_not_remove_listeners_for_other():void
		{
			var called:Array = [];
			var loser:Object = {};
			var keeper:Object = {};
			var createHandler:Function = function(ownerName:String):Function {
				return function(event:Event):void {
					called.push(ownerName);
				}
			};
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, createHandler('loser'), SampleEvent, loser);
			subject.mapRelaxedListener(SampleEvent.SOMETHING_HAPPENED, createHandler('keeper'), SampleEvent, keeper);
			subject.unmapListenersFor(loser);
			eventDispatcher.dispatchEvent(new SampleEvent(SampleEvent.SOMETHING_HAPPENED));
			assertThat(called, array('keeper'));
		}
	}
}
