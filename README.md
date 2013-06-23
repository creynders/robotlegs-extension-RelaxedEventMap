# Relaxed Event Map

## Overview

The Relaxed Event Map allows to register listeners with the shared event dispatcher for events that already have been dispatched.
It facilitates in dealing with racing conditions, where e.g. a model has already sent an update event before a mediator that listens for that event has been instantiated.

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

## Unmapping all listeners for an object

You can pass an 'owner' object as a fourth parameter to the mapping method and unmap all listeners at once with `unmapListenersFor`.

```as3
relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_UPDATED, updatedHandler, SomeDataEvent, this);
relaxedEventMap.mapRelaxedListener(SomeDataEvent.DATA_SET_DELETED, deletedHandler, SomeDataEvent, this);    
	
relaxedEventMap.unmapListenersFor(this);
```
 
# Relaxed Event Map Extension

## Requirements

This extension requires the following extensions:

+ EventDispatcherExtension
+ LocalEventMapExtension

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
