//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.relaxedEventMap.api
{

	/**
	 * The Relaxed Event Map allows to register listeners with the shared event dispatcher for events that possibly already have been dispatched.
	 */
	public interface IRelaxedEventMap
	{
		/**
		 * Registers a listener. If the event already has been dispatched, the listener will be called immediately, i.e. synchronously.
		 * @param type The <code>Event</code> type
		 * @param listener The <code>Event</code> handler
		 * @param eventClass Optional Event class for a stronger mapping. Defaults to <code>flash.events.Event</code>.
		 * @param key A key to identify a group of listeners
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */
		function mapRelaxedListener(type:String,
			listener:Function,
			eventClass:Class = null,
			key:* = null,
			useCapture:Boolean = false,
			priority:int = 0,
			useWeakReference:Boolean = true):void;

		/**
		 * Removes a listener registered through <code>mapRelaxedListener</code>
		 * @param type The <code>Event</code> type
		 * @param listener The <code>Event</code> handler
		 * @param eventClass Optional Event class for a stronger mapping. Defaults to <code>flash.events.Event</code>.
		 * @param key A key to identify a group of listeners
		 * @param useCapture
		 */
		function unmapRelaxedListener(type:String,
			listener:Function,
			eventClass:Class = null,
			key:* = null,
			useCapture:Boolean = false):void;

		/**
		 * Registers an event
		 * @param type
		 * @param eventClass
		 */
		function rememberEvent(type:String, eventClass:Class = null):void;

		/**
		 * Removes all listeners registered through <code>mapRelaxedListener</code> for a specific <code>key</code>.
		 * @param key A key to identify a group of listeners
		 */
		function unmapListenersFor(key:*):void;
	}
}
