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
	import robotlegs.bender.extensions.localEventMap.impl.EventMapConfig;
	import robotlegs.bender.extensions.relaxedEventMap.api.IRelaxedEventMap;
	import robotlegs.bender.framework.api.ILogger;

	public class RelaxedEventMap extends EventMap implements IRelaxedEventMap
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _configsByKey:Dictionary;

		private function get configsByKey():Dictionary
		{
			return _configsByKey || (_configsByKey = new Dictionary());
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
				configsByKey[key] ||= new Vector.<EventMapConfig>();
				const config:EventMapConfig = new EventMapConfig(
					_eventDispatcher,
					type,
					listener,
					eventClass,
					unmapListener,
					useCapture
					);
				configsByKey[key].push(config);
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
			key && removeConfigFromList(listener, key);
		}

		/**
		 * @inheritDoc
		 */
		public function unmapListenersFor(key:*):void
		{
			const configs:Vector.<EventMapConfig> = configsByKey[key];
			if (configs == null) return;

			for each (var config:EventMapConfig in configs)
			{
				config.callback.call(this, config.dispatcher, config.eventString,
					config.listener, config.eventClass, config.useCapture);
			}

			delete configsByKey[key];
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

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function removeConfigFromList(listener:Function, key:*):void
		{
			var configs:Vector.<EventMapConfig> = configsByKey[key]
			if (configs && configs.length > 0)
			{
				var i:int = configs.length;
				while (i--)
				{
					var config:EventMapConfig = configs[i];
					if (config.listener === listener)
					{
						configs.splice(i, 1);
						if( configs.length <= 0){
							delete configsByKey[key];
						}
						return;
					}
				}
			}
		}
	}
}

