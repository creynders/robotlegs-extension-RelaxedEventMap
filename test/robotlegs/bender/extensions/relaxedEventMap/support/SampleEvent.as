//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.relaxedEventMap.support
{
	import flash.events.Event;

	public class SampleEvent extends Event
	{

		/*============================================================================*/
		/* Public Static Properties                                                   */
		/*============================================================================*/

		public static const SOMETHING_HAPPENED:String = 'somethingHappened';

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function SampleEvent(type:String)
		{
			super(type);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		override public function clone():Event
		{
			return new SampleEvent(type);
		}
	}
}
