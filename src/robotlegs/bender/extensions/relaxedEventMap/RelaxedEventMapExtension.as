//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.relaxedEventMap
{
	import robotlegs.bender.extensions.relaxedEventMap.api.IRelaxedEventMap;
	import robotlegs.bender.extensions.relaxedEventMap.impl.RelaxedEventMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;

	public class RelaxedEventMapExtension implements IExtension
	{

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function extend(context:IContext):void
		{
			context.injector.map(IRelaxedEventMap).toSingleton(RelaxedEventMap);
		}
	}
}
