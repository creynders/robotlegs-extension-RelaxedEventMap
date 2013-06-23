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
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import robotlegs.bender.extensions.localEventMap.impl.EventMap;
	import robotlegs.bender.extensions.relaxedEventMap.api.IRelaxedEventMap;
	import robotlegs.bender.framework.api.ILogger;

	public class RelaxedEventMap extends EventMap implements IRelaxedEventMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _unmappingsByOwner:Dictionary;

		private function get unmappingsByOwner():Dictionary
		{
			return _unmappingsByOwner || (_unmappingsByOwner = new Dictionary());
		}

		private var _eventsReceivedByClass:Dictionary;

		private var _emptyListeners:Array;

		private var _eventDispatcher:IEventDispatcher;

		private var _logger:ILogger;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function RelaxedEventMap(eventDispatcher:IEventDispatcher, logger:ILogger = null)
		{
			super();
			_eventDispatcher = eventDispatcher;
			_eventsReceivedByClass = new Dictionary();
			_emptyListeners = [];
			_logger = logger;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function mapRelaxedListener(
			type:String,
			listener:Function,
			eventClass:Class = null,
			ownerObject:* = null,
			useCapture:Boolean = false,
			priority:int = 0,
			useWeakReference:Boolean = true):void
		{
			eventClass ||= Event;
			if ((_eventsReceivedByClass[eventClass] != null) && (_eventsReceivedByClass[eventClass][type] != null))
			{
				var eventToSupply:Event = _eventsReceivedByClass[eventClass][type];
				var temporaryDispatcher:EventDispatcher = new EventDispatcher();
				temporaryDispatcher.addEventListener(type, listener);
				temporaryDispatcher.dispatchEvent(eventToSupply);
			}

			if (ownerObject != null)
			{
				unmappingsByOwner[ownerObject] ||= [];
				var unmapping:Function = function():void
				{
					unmapRelaxedListener(type, listener, eventClass, useCapture);
				}
				unmappingsByOwner[ownerObject].push(unmapping);
			}

			mapListener(this._eventDispatcher, type, listener, eventClass, useCapture, priority, useWeakReference);
		}

		public function unmapRelaxedListener(
			type:String,
			listener:Function,
			eventClass:Class = null,
			ownerObject:* = null,
			useCapture:Boolean = false):void
		{
			unmapListener(this._eventDispatcher, type, listener, eventClass, useCapture);
		}

		public function rememberEvent(type:String, eventClass:Class = null):void
		{
			var emptyListener:Function = function():void {
			};
			_emptyListeners.push(emptyListener);
			mapListener(this._eventDispatcher, type, emptyListener, eventClass);
		}

		public function unmapListenersFor(ownerObject:*):void
		{
			if (unmappingsByOwner[ownerObject] == null) return;

			for each (var unmapping:Function in unmappingsByOwner[ownerObject])
			{
				unmapping();
			}

			delete unmappingsByOwner[ownerObject];
			_logger && _logger.debug('Relaxed event listeners unmapped for {0}', [ownerObject]);
		}

		/*============================================================================*/
		/* Protected Functions                                                        */
		/*============================================================================*/

		override protected function routeEventToListener(event:Event, listener:Function, originalEventClass:Class):void
		{
			if (event is originalEventClass)
			{
				_eventsReceivedByClass[originalEventClass] ||= new Dictionary();
				_eventsReceivedByClass[originalEventClass][event.type] = event;

				if (_emptyListeners.indexOf(listener) == -1)
				{
					listener(event);
				}

			}
		}
	}
}
