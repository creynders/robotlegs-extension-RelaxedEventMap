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

		private var _unmappingsByKey:Dictionary;

		private function get unmappingsByKey():Dictionary
		{
			return _unmappingsByKey || (_unmappingsByKey = new Dictionary());
		}

		private var _eventsReceivedByClass:Dictionary;

		private var _emptyListeners:Array;

		private var _eventDispatcher:IEventDispatcher;

		private var _logger:ILogger;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
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

		/**
		 * @inheritDoc
		 */
		public function rememberEvent(type:String, eventClass:Class = null):void
		{
			var emptyListener:Function = function():void {
			};
			_emptyListeners.push(emptyListener);
			mapListener(this._eventDispatcher, type, emptyListener, eventClass);
		}

		/**
		 * @inherit
		 */
		public function mapRelaxedListener(
			type:String,
			listener:Function,
			eventClass:Class = null,
			key:* = null,
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

			if (key != null)
			{
				unmappingsByKey[key] ||= [];
				var unmapping:Function = function():void
				{
					unmapRelaxedListener(type, listener, eventClass, useCapture);
				}
				unmappingsByKey[key].push(unmapping);
			}

			mapListener(this._eventDispatcher, type, listener, eventClass, useCapture, priority, useWeakReference);
		}

		/**
		 * @inheritDoc
		 */
		public function unmapRelaxedListener(
			type:String,
			listener:Function,
			eventClass:Class = null,
			key:* = null,
			useCapture:Boolean = false):void
		{
			unmapListener(this._eventDispatcher, type, listener, eventClass, useCapture);
		}

		/**
		 * @inheritDoc
		 */
		public function unmapListenersFor(key:*):void
		{
			if (unmappingsByKey[key] == null) return;

			for each (var unmapping:Function in unmappingsByKey[key])
			{
				unmapping();
			}

			delete unmappingsByKey[key];
			_logger && _logger.debug('Relaxed event listeners unmapped for {0}', [key]);
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
