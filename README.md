# Relaxed Event Map

## Overview

An extension for Robotlegs v2.

The Relaxed Event Map allows to register listeners with the shared event dispatcher for events that already have been dispatched.
It facilitates in dealing with racing conditions, where e.g. a model has already sent an update event before a mediator that listens for that event has been instantiated.

### Notes:

* Requires a Robotlegs version greater than v2.0.0, depends on a change made in commit [0a9e40b](https://github.com/robotlegs/robotlegs-framework/commit/0a9e40b4204a32a563f206e7d5f3b4cb8ff7bcf6) 
* This is a direct port from Stray's [robotlegs-utilities-relaxedeventmap](https://github.com/Stray/robotlegs-utilities-RelaxedEventMap) for Robotlegs v1

## Basic Usage

It is necessary to tell the Relaxed Event Map to remember an event and store the last dispatched instance.

```as3
relaxedEventMap.rememberEvent(FooEvent.Foo, FooEvent);
```

If you register a listener for this event it will be called even if the event has already been dispatched.

```as3    
eventDispatcher.dispatchEvent(new FooEvent(FooEvent.FOO));
relaxedEventMap.mapRelaxedListener(FooEvent.Foo, listener, FooEvent); //handler will be called immediately, i.e. synchronously
```       

## Unmapping specific listeners

```as3
relaxedEventMap.unmapRelaxedListener(FooEvent.Foo, listener, FooEvent);
```

## Unmapping all listeners for a key

You can pass a key as a fourth parameter to the mapping method and unmap all listeners at once with `unmapListenersFor`.

```as3
relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_UPDATED, updatedHandler, SomeDataEvent, this); //'this' used as key
relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_DELETED, deletedHandler, SomeDataEvent, this); //'this' used as key
	
relaxedEventMap.unmapListenersFor(this); //'this' used as key
```
 
# Relaxed Event Map Extension

## Requirements

This extension requires the following extensions:

+ EventDispatcherExtension

## Extension Installation

```as3
_context = new Context().install(
    EventDispatcherExtension,
    RelaxedEventMapExtension);
```

Or, assuming that the EventDispatcherExtension has already been installed:

```as3
_context.install(RelaxedEventMapExtension);
```

## Extension Usage

An instance of IRelaxedEventMap is mapped into the context during extension installation. This instance can be injected into clients and used as below.

```as3
[Inject]
public var relaxedEventMap:IRelaxedEventMap;
```
