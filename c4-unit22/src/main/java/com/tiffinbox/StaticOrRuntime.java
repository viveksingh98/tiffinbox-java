package com.tiffinbox;

import org.springframework.aop.aspectj.AspectJExpressionPointcut;

/**
 * Why the class-name detector has a blind spot, asked of the pointcut itself. A runtime-checked
 * pointcut is only PARTLY decided when the proxy is built - so the proxy exists for methods that
 * merely COULD match. Here the only such method on MenuService is equals(Object): a String could be
 * passed to it. The third row (added after the section's RED review) is why the right-hand column, not
 * isRuntime(), is the test: @annotation also answers "checked at run time: true", yet it can rule out
 * every MenuService method before anything runs - so the menu bean stays plain under it (Matrix row).
 */
public final class StaticOrRuntime {

    private StaticOrRuntime() { }

    public static void main(String[] args) {
        for (String e : new String[]{"args(String)", "execution(* *(String))", "@annotation(com.tiffinbox.Audited)"}) {
            AspectJExpressionPointcut pc = new AspectJExpressionPointcut();
            pc.setExpression(e);
            StringBuilder could = new StringBuilder();
            for (var m : MenuService.class.getMethods()) {
                if (pc.getMethodMatcher().matches(m, MenuService.class)) {
                    could.append(m.getName()).append('(').append(m.getParameterTypes().length == 1
                            ? m.getParameterTypes()[0].getSimpleName() : "").append(") ");
                }
            }
            System.out.printf("  %-35s checked at run time: %-5s  MenuService methods that COULD match: %s%n",
                    e, pc.getMethodMatcher().isRuntime(), could.length() == 0 ? "none" : could.toString().trim());
        }
    }
}
