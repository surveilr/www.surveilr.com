import * as dotenv from "dotenv";
import Logger from "../utils/logger-util";

dotenv.config({ path: ".env" });

export const logger = new Logger();
