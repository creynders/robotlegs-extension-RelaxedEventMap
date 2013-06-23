//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.relaxedEventMap
{
	import org.hamcrest.assertThat;
	import org.hamcrest.object.instanceOf;
	import robotlegs.bender.extensions.eventDispatcher.EventDispatcherExtension;
	import robotlegs.bender.extensions.localEventMap.LocalEventMapExtension;
	import robotlegs.bender.extensions.relaxedEventMap.api.IRelaxedEventMap;
	import robotlegs.bender.extensions.relaxedEventMap.impl.RelaxedEventMap;
	import robotlegs.bender.framework.impl.Context;

	public class RelaxedEventMapExtensionTest
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var context:Context;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			context = new Context();
			context.install(
				EventDispatcherExtension,
				LocalEventMapExtension,
				RelaxedEventMapExtension);
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function relaxedEventMap_is_mapped_into_injector():void
		{
			var actual:Object = null;
			context.whenInitializing(function():void {
				actual = context.injector.getInstance(IRelaxedEventMap);
			});
			context.initialize();
			assertThat(actual, instanceOf(RelaxedEventMap));
		}
	}
}
