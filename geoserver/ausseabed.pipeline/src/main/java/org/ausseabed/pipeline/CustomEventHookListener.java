package org.ausseabed.pipeline;

// From https://github.com/Valemobi/tomcat-events-hook

import org.apache.catalina.Lifecycle;
import org.apache.catalina.LifecycleEvent;
import org.apache.catalina.LifecycleListener;

/**
 * Simple class to hookup events to external scripts
 *
 * @author gustavo
 */
public class CustomEventHookListener implements LifecycleListener {
    @Override
    public void lifecycleEvent(LifecycleEvent arg0) {
        Lifecycle lifecycle = arg0.getLifecycle();
        if (lifecycle == null) {
            return;
        }
        String type = arg0.getType();
        if (type == null) {
            return;
        }
        String stateName = lifecycle.getStateName();
        if (stateName == null) {
            return;
        }
        if (type.equals("after_start") && stateName.equals("STARTED")) {
            startPostInitScript();
        }
    }

    private void startPostInitScript() {
        // Non-blocking please.
        Thread t = new Thread() {
            @Override
            public void run() {
                try {
                    super.run();
                    // Simple lookup for scripts. Should be a function and unified to hookup
                    // other events, but let's first solve our problem.
                    String script = null;
                    script = System.getProperty("post.init.script");
                    if (script == null) {
                        System.err.println("Post-init script not found in System.getProperty");
                        script = System.getenv().get("TOMCAT_POST_INIT_SCRIPT");
                        if (script == null) {
                            System.err.println("Variable TOMCAT_POST_INIT_SCRIPT not found in environment");
                            throw new Exception("Aborting script execution (since there's no script to run)");
                        }
                    }
                    System.out.println("Running " + script);
                    // inheritIO to output things to JVM.
                    new ProcessBuilder().command(script).inheritIO().start()
                            .waitFor();
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            }
        };
        t.setDaemon(true);
        t.start();
    }
}