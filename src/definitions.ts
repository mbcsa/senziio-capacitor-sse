export interface SenziioSSEPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
